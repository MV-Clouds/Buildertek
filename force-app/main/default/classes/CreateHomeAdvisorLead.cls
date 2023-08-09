@RestResource(urlMapping='/CreateHomeAdvisorLead/*')
global with sharing class CreateHomeAdvisorLead {
    @HttpPost
    global static ResponseClass createLeadRecord(){
        ResponseClass rc = new ResponseClass();
        try{
        	RestRequest req = RestContext.request;
            RestResponse res = Restcontext.response;
            String requestBody = RestContext.request.requestBody.toString();
            String payloadBody = '';
            if(requestBody.contains('"end"')){
                requestBody = requestBody.replace('"end"', '"endDate"');    
            }
            LeadData leadRecordData = (LeadData)System.JSON.deserialize(requestBody, LeadData.class);
            system.debug('DESERIALIZED-----> '+ leadRecordData);
            Lead ld = new Lead();
            ld.FirstName =  leadRecordData.firstName;
            ld.LastName = leadRecordData.lastName;
            ld.Email = leadRecordData.email;
            ld.Company = leadRecordData.spCompanyName;
            ld.Street = leadRecordData.address;
            ld.City = leadRecordData.city;
            ld.State = leadRecordData.stateProvince;
            ld.PostalCode = leadRecordData.postalCode;
            ld.Phone = leadRecordData.primaryPhone;
            ld.buildertek__Phone_Ext__c = leadRecordData.phoneExt;
            ld.buildertek__Secondary_Phone__c = leadRecordData.secondaryPhone;
            ld.buildertek__Secondary_Phone_Ext__c = leadRecordData.secondaryPhoneExt;
            ld.Description = leadRecordData.leadDescription;
            ld.buildertek__SR_Id__c = leadRecordData.srOid;
            ld.buildertek__Lead_Id__c = leadRecordData.leadOid;
            ld.buildertek__Task_Id__c = leadRecordData.taskOid;
            ld.buildertek__Task_Name__c = leadRecordData.taskName;
            ld.buildertek__CRM_Key__c = leadRecordData.crmKey;
            ld.buildertek__SP_Partner_Id__c = leadRecordData.spPartnerId;
            ld.buildertek__SP_Entity_Id__c = leadRecordData.spEntityId;
            ld.buildertek__Contact_Status__c = leadRecordData.contactStatus;
            ld.buildertek__Comments__c = leadRecordData.comments;
            ld.buildertek__Match_Type__c = leadRecordData.matchType;
            insert ld;
            if(ld != null){
                if(leadRecordData.interview.size() > 0){
                    List<buildertek__Interview__c> interviewList = new List<buildertek__Interview__c>();
                    for(Interview iv : leadRecordData.interview){
                        buildertek__Interview__c interview = new buildertek__Interview__c();
                        interview.buildertek__Question__c = iv.question;
                        interview.buildertek__Answer__c = iv.answer;
                        interview.buildertek__Lead__c = ld.Id;
                        interviewList.add(interview);
                    } 
                    if(interviewList.size() > 0){
                        insert interviewList;    
                    }
                }  
                if(leadRecordData.appointment != null){
                    buildertek__Appointment__c appointment = new buildertek__Appointment__c();  
                    appointment.buildertek__Appointment_Id__c = leadRecordData.appointment.appointmentOid;
                    appointment.buildertek__End_Date__c = convertToDateTime(leadRecordData.appointment.endDate);
                    appointment.buildertek__External_Id__c = leadRecordData.appointment.external_id;
                    appointment.buildertek__Lead__c = ld.Id;
                    appointment.buildertek__Start_Date__c = convertToDateTime(leadRecordData.appointment.start);
                    appointment.buildertek__Status__c = leadRecordData.appointment.status;
                    appointment.buildertek__Type__c = leadRecordData.appointment.type;
                    insert appointment;
                }
            } 
            rc.statusCode = 200;
            rc.success = true;
            rc.message = 'Lead created';
            return rc;
        }catch(Exception exp){
        	rc.statusCode = 400;
            rc.success = false;
            rc.message = exp.getMessage();
            return rc;           
        }
        
    }
    
    global static DateTime convertToDateTime(String dateTimeToConvert){
        String StringTime = dateTimeToConvert;
        List<String> DateAndTimeList = StringTime.split('T');
        List<String> dayList = DateAndTimeList[0].split('-'); 
        List<string> timeList = DateAndTimeList[1].split(':');
        DateTime dt = DateTime.newInstance(Integer.valueOf(dayList[0]), Integer.valueOf(dayList[1]), Integer.valueOf(dayList[2]), Integer.valueOf(timeList[0]), Integer.valueOf(timeList[1]), Integer.valueOf(timeList[2].split('\\.')[0]));
        System.debug('DateTime is : '+dt);
        return dt;
    }
    
    global class LeadData{
        global string name;
        global string firstName;
        global string lastName;
        global string address;
        global string city;
        global string stateProvince;
        global string postalCode;
        global string primaryPhone;
        global string phoneExt;
        global string secondaryPhone;
        global string secondaryPhoneExt;
        global string email;
        global string srOid;
        global string leadOid;
        global string taskOid;
        global string taskName;
        global string spPartnerId;
        global string crmKey;
        global string contactStatus;
        global string comments;
        global string matchType;
        global string leadDescription;
        global string spEntityId;
        global string spCompanyName;
        global List<Interview> interview;
        global Appointment appointment;
    }
    
    global class Interview{
        global string question;
        global string answer;
        global Interview(string question, string answer){
            this.question = question;
            this.answer = answer;
        }
    }
    
    global class Appointment{
     	global string appointmentOid;
        global string status;
        global string type;
        global string start;
        global string endDate;
        global string external_id;
    }
    
    global class ResponseClass{
        global Integer statusCode;
        global Boolean success;
        global String message;
    }
}