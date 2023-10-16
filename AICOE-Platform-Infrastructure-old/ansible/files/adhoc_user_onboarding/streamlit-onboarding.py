import streamlit as st
import boto3
import logging
from botocore.exceptions import ClientError
import os
import datetime
import re

class app:
    def __init__(self):
        self.workdir='/home/ec2-user/src/profiles/adhoc_onboarding/'
        if 'users' not in st.session_state:
            st.session_state.users=None
        if 'namespace' not in st.session_state:
            st.session_state.namespace=None
        if 'admin' not in st.session_state:
            st.session_state.lead=None
        if 'username' not in st.session_state:
            st.session_state.username=None
        if 'request_type' not in st.session_state:
            st.session_state.request_type=None
        if 'button' not in st.session_state:
            st.session_state.button = False
        if 'users_email_validated' not in st.session_state:
            st.session_state.users_email_validated=False
        if 'admin_email_validated' not in st.session_state:
            st.session_state.admin_email_validated=False
    
    def check_password(self):
        """Returns `True` if the user had a correct password."""
        st.title("Login to OptiML User Onboarding")
        def password_entered():
            """Checks whether a password entered by the user is correct."""
            if (
                st.session_state["username"] in st.secrets["passwords"]
                and st.session_state["password"]
                == st.secrets["passwords"][st.session_state["username"]]
            ):
                st.session_state["password_correct"] = True
                del st.session_state["password"]  # don't store username + password
            else:
                st.session_state["password_correct"] = False

        if "password_correct" not in st.session_state:
            # First run, show inputs for username + password.
            st.session_state.username=st.text_input("Username", on_change=password_entered)
            st.text_input(
                "Password", type="password", on_change=password_entered, key="password"
            )
            return False
        elif not st.session_state["password_correct"]:
            # Password not correct, show input + error.
            st.session_state.username=st.text_input("Username", on_change=password_entered)
            st.text_input(
                "Password", type="password", on_change=password_entered, key="password"
            )
            st.error("😕 User not known or password incorrect")
            return False
        else:
            # Password correct.
            return True

    def logging(self): #,request_type,username,namespace,users,admin=None
        s3c=boto3.client('s3')
        Bucket="{{ platform_metadata_bucket_name }}"
        file_name='onboarding_log.csv'
        key="onboarding/{{ cluster_name }}/"+file_name
        
        try:
            #check if log file exists or not
            s3c.head_object(Bucket=Bucket,Key=key)
            s3c.download_file(Bucket, key, file_name)
            with open(file_name,'a') as file:
                if st.session_state.admin!=None:
                    data=f"{datetime.datetime.now()},{st.session_state.username},{st.session_state.request_type},{st.session_state.namespace},{st.session_state.admin},{st.session_state.users}\n"
                else:
                    data=f"{datetime.datetime.now()},{st.session_state.username},{st.session_state.request_type},{st.session_state.namespace},,{st.session_state.users}\n"
                file.write(data)
        except ClientError as e:
            with open(file_name,'w') as file:
                if st.session_state.admin!=None:
                    data=f"{datetime.datetime.now()},{st.session_state.username},{st.session_state.request_type},{st.session_state.namespace},{st.session_state.admin},{st.session_state.users}\n"
                else:
                    data=f"{datetime.datetime.now()},{st.session_state.username},{st.session_state.request_type},{st.session_state.namespace},,{st.session_state.users}\n"
                file.write(data)

        try:
            response = s3c.upload_file(file_name, Bucket, key)
        except ClientError as e:
            logging.error(e)
            return False

    def verify_email(self,email):
        regex = r'\b[A-Za-z0-9._%+-]+@deloitte.com\b'
        return re.fullmatch(regex, email)

    def namespace_onboarding(self):
        st.subheader("Provide following details for creating namespace and onboarding users:")
        st.session_state.namespace = st.text_input("Namespace name")
        st.session_state.admin = st.text_input("Namespace admin email (eg. abc@deloitte.com)")
        if self.verify_email(st.session_state.admin):
            st.session_state.admin=st.session_state.admin.replace('@deloitte.com','')
            st.session_state.admin_email_validated=True
        else:
            if st.session_state.admin!='':
                st.error('Please enter correct email')
        st.session_state.users = st.text_input("Users' email (as a comma seperated list, example: abc@deloitte.com,def@deloitte.com)")
        st.session_state.user_list=st.session_state.users.replace(' ','').split(',')
        st.session_state.users_email_validated=True
        for i,email in enumerate(st.session_state.user_list):
            if self.verify_email(email):
                st.session_state.user_list[i]=st.session_state.user_list[i].replace('@deloitte.com','')
            else:
                if email!='':
                    st.error(f'Please enter correct email: {email}')
                    st.session_state.users_email_validated=False
        st.session_state.user_list=' '.join(st.session_state.user_list)
        
        if st.session_state.users_email_validated and st.session_state.admin_email_validated:
            if(st.button('Create namespace and onboard user')):
                return_code=os.system(f"kubectl get profiles | grep -wq {st.session_state.namespace}")
                if return_code!=0:
                    os.chdir(self.workdir)
                    os.system(f'bash {self.workdir}profile_create_ns.sh {st.session_state.namespace} {st.session_state.admin} "{st.session_state.user_list}"')
                    st.text("Done, for verification, please click below")
                    self.logging()
                    st.session_state.button=True
                else:
                    if st.session_state.namespace!='':
                        st.error("Namespace already exist")

        if st.session_state.button:
            if (st.button('Verify the namespace and users')):
                if os.system(f'kubectl get profiles {st.session_state.namespace}')==0:
                    st.success("Namespace created successfully")
                    for user in st.session_state.user_list.split(' '):
                        if user=='':
                            pass
                        else:
                            if os.system(f'kubectl get rolebinding -n {st.session_state.namespace} | grep -w user-{user}-deloitte-com-clusterrole-edit')==0:
                                st.success(f'User: {user} onboarded to namespace: {st.session_state.namespace} successfully')
                            else:
                                st.error(f'User: {user} not onboarded, please check')
                else:
                    st.error(f'Namespace not created, please check')

    def user_onboarding(self):
        st.subheader("Provide following details to add users to existing namespace")
        st.session_state.namespace = st.text_input("Namespace name")
        return_code=os.system(f"kubectl get profiles | grep -wq {st.session_state.namespace}")
        if return_code==0:
            st.session_state.users = st.text_input("Users' email (as a comma seperated list, example: abc@deloitte.com,def@deloitte.com)")
            st.session_state.user_list=st.session_state.users.replace(' ','').split(',')
            st.session_state.users_email_validated=True
            for i,email in enumerate(st.session_state.user_list):
                if self.verify_email(email):
                    st.session_state.user_list[i]=st.session_state.user_list[i].replace('@deloitte.com','')
                else:
                    if email!='':
                        st.error(f'Please enter correct email: {email}')
                        st.session_state.users_email_validated=False
            
            st.session_state.user_list=' '.join(st.session_state.user_list)
            
            if st.session_state.users_email_validated:
                if(st.button('Onboard user')):
                    os.chdir(self.workdir)
                    os.system(f'bash {self.workdir}profile_add_users.sh {st.session_state.namespace} "{st.session_state.user_list}"')
                    st.text(f"Added users to the namespace {st.session_state.namespace}")
                    self.logging()
                    st.session_state.button=True
                if st.session_state.button:
                    if(st.button('Verify the users')):
                        for user in st.session_state.user_list.split(' '):
                            if user=='':
                                pass
                            else:
                                if os.system(f'kubectl get rolebinding -n {st.session_state.namespace} | grep -w user-{user}-deloitte-com-clusterrole-edit')==0:
                                    st.success(f'User: {user} onboarded to namespace: {st.session_state.namespace} successfully')
                                else:
                                    st.error(f'User: {user} not onboarded, please check')
        else:
            if st.session_state.namespace!='':
                st.error("Namespace does not exist")

    def main(self):
        if self.check_password():
            st.title("User Onboarding")
            st.session_state.request_type=None
            types=('Namespace and User Onboarding', 'User Onboarding')
            st.session_state.request_type = st.radio("Onboarding Type: ", types)
            if st.session_state.request_type==types[0]:
                self.namespace_onboarding()
            else:
                self.user_onboarding()

if __name__=='__main__':
    app=app()
    app.main()