/*
Name                :  SDProjectTrackingHistory 
Author              :  View Inc.
Release             :  2
Functionality       :  Additional Field History Tracking on SD Project Tracking
Created             :  6/14/2018

Modification History:
Data             Author                   Change
08/03/2018       View Inc.              Created New "Field__c" to capture API Names of all delivery asks and System Design Re-Commit.
*/
trigger SDProjectTrackingHistory on SD_Project_Tracking__c (After update) {
    Map<id,SD_Project_Tracking__c > oldMap=Trigger.OldMap;
    List<SD_Resource_Tracking__c> listOfHistory=new List<SD_Resource_Tracking__c> ();
    if(Trigger.Isafter && Trigger.Isupdate){
            if(checkRecursive.runOnceSDTrack()){
   
                for(SD_Project_Tracking__c sptObj: Trigger.New){
                //Final Delivery Ask 
                    if( sptObj.Final_Delivery_ask__c!= oldMAp.Get(sptObj.id).Final_Delivery_ask__c){
         
                            SD_Resource_Tracking__c srtHistory=new SD_Resource_Tracking__c();
                            srtHistory.SD_Project_Tracking_History__c=sptObj.id;
                            srtHistory.Date__c=System.Now();            
                            srtHistory.User__c=userInfo.getUserId();
                            String oldvalue='';
                            String str='';
             
                            if(oldMAp.Get(sptObj.id).Final_Delivery_ask__c!=null){
                                str='Changed';
                                srtHistory.NewValue__c=sptObj.Final_Delivery_ask__c!=null?sptObj.Final_Delivery_ask__c.format():'';
                                srtHistory.OldValue__c=oldMAp.Get(sptObj.id).Final_Delivery_ask__c.format();
                                oldValue=oldMAp.Get(sptObj.id).Final_Delivery_ask__c.format();
                                if(sptObj.Final_Delivery_ask__c==null)
                                {
                                    str='Deleted';
                                    srtHistory.Action__C=str+' '+oldValue +' In '+Schema.SD_Project_Tracking__c.fields.Final_Delivery_ask__c.getDescribe().getLabel();  
                                    // Added to capture all PM Delviery Ask's and System Design Re-commit API Names 
                                    srtHistory.Field__c =  Schema.SD_Project_Tracking__c.fields.Final_Delivery_ask__c.getDescribe().getName(); 
                                }
                                else
                                {
                                    srtHistory.Action__C=Str+' '+Schema.SD_Project_Tracking__c.fields.Final_Delivery_ask__c.getDescribe().getLabel() +' ' + ' From ' +oldValue + ' to ' + srtHistory.NewValue__c ; 
                                    // Added to capture all PM Delviery Ask's and System Design Re-commit API Names 
                                    srtHistory.Field__c =  Schema.SD_Project_Tracking__c.fields.Final_Delivery_ask__c.getDescribe().getName(); 
                                }           
                            }
                            else
                            {
                                str='Changed';
                                srtHistory.NewValue__c=sptObj.Final_Delivery_ask__c!=null?sptObj.Final_Delivery_ask__c.format():'';
                                srtHistory.Action__C=  str+' '+Schema.SD_Project_Tracking__c.fields.Final_Delivery_ask__c.getDescribe().getLabel() +' ' + ' to  ' + srtHistory.NewValue__c;
                                // Added to capture all PM Delviery Ask's and System Design Re-commit API Names
                                srtHistory.Field__c =  Schema.SD_Project_Tracking__c.fields.Final_Delivery_ask__c.getDescribe().getName(); 
                            }
                 
                            listOfHistory.add(srtHistory) ;
                    } 
                    // Revised Prelim Delivery Ask
                    if( sptObj.Revised_Prelim_Delivery_ask__c!= oldMAp.Get(sptObj.id).Revised_Prelim_Delivery_ask__c){
                        SD_Resource_Tracking__c srtHistory=new SD_Resource_Tracking__c();
                        srtHistory.SD_Project_Tracking_History__c=sptObj.id;
                        srtHistory.Date__c=System.Now();            
                        srtHistory.User__c=userInfo.getUserId();
            
                        String oldvalue='';
                        String str='';
                        if(oldMAp.Get(sptObj.id).Revised_Prelim_Delivery_ask__c!=null){
                            str='Changed';
                            srtHistory.NewValue__c=sptObj.Revised_Prelim_Delivery_ask__c!=null?sptObj.Revised_Prelim_Delivery_ask__c.format():'';
                            srtHistory.OldValue__c=oldMAp.Get(sptObj.id).Revised_Prelim_Delivery_ask__c.format();
                            oldValue=oldMAp.Get(sptObj.id).Revised_Prelim_Delivery_ask__c.format();
                            if(sptObj.Revised_Prelim_Delivery_ask__c==null){
                                str='Deleted';
                                srtHistory.Action__C=str+' '+oldValue +' In '+Schema.SD_Project_Tracking__c.fields.Revised_Prelim_Delivery_ask__c.getDescribe().getLabel();  
                                // // Added to capture all PM Delviery Ask's and System Design Re-commit API Names
                                srtHistory.Field__c =  Schema.SD_Project_Tracking__c.fields.Revised_Prelim_Delivery_ask__c.getDescribe().getName(); 
                            }
                            else
                            {
                                str='Changed';
                                srtHistory.Action__C=str+' '+Schema.SD_Project_Tracking__c.fields.Revised_Prelim_Delivery_ask__c.getDescribe().getLabel() +' ' + ' From ' +oldValue + ' to ' + srtHistory.NewValue__c ; 
                                srtHistory.Field__c =  Schema.SD_Project_Tracking__c.fields.Revised_Prelim_Delivery_ask__c.getDescribe().getName(); 
                            }           
                        }
                        else
                        {
                 
                            str='Changed';
                            srtHistory.NewValue__c=sptObj.Revised_Prelim_Delivery_ask__c!=null?sptObj.Revised_Prelim_Delivery_ask__c.format():'';
                            srtHistory.Action__C=  str+' '+Schema.SD_Project_Tracking__c.fields.Revised_Prelim_Delivery_ask__c.getDescribe().getLabel() +' ' + ' to  ' + srtHistory.NewValue__c;
                            srtHistory.Field__c =  Schema.SD_Project_Tracking__c.fields.Revised_Prelim_Delivery_ask__c.getDescribe().getName(); 
                        }
                 
                        listOfHistory.add(srtHistory) ;
                    }
                    // Prelim Int Delivery Ask
                    if( sptObj.Prelim_Int_delivery_ask__c!= oldMAp.Get(sptObj.id).Prelim_Int_delivery_ask__c){
                        SD_Resource_Tracking__c srtHistory=new SD_Resource_Tracking__c();
                        srtHistory.SD_Project_Tracking_History__c=sptObj.id;
                        srtHistory.Date__c=System.Now();            
                        srtHistory.User__c=userInfo.getUserId();
            
                        String oldvalue='';
                        String str='Changed';
                        if(oldMAp.Get(sptObj.id).Prelim_Int_delivery_ask__c!=null){
            
                            srtHistory.NewValue__c=sptObj.Prelim_Int_delivery_ask__c!=null?sptObj.Prelim_Int_delivery_ask__c.format():'';
                            srtHistory.OldValue__c=oldMAp.Get(sptObj.id).Prelim_Int_delivery_ask__c.format();
                            oldValue=oldMAp.Get(sptObj.id).Prelim_Int_delivery_ask__c.format();
                            if(sptObj.Prelim_Int_delivery_ask__c==null){
                                str='Deleted';
                                srtHistory.Action__C=str+' '+oldValue +' In '+Schema.SD_Project_Tracking__c.fields.Prelim_Int_delivery_ask__c.getDescribe().getLabel();  
                                srtHistory.Field__c =  Schema.SD_Project_Tracking__c.fields.Prelim_Int_delivery_ask__c.getDescribe().getName(); 
                            }
                            else
                            {
              
                                srtHistory.Action__C=str+' '+Schema.SD_Project_Tracking__c.fields.Prelim_Int_delivery_ask__c.getDescribe().getLabel() +' ' + ' From ' +oldValue + ' to ' + srtHistory.NewValue__c ; 
                                srtHistory.Field__c =  Schema.SD_Project_Tracking__c.fields.Prelim_Int_delivery_ask__c.getDescribe().getName(); 
                            }           
                        }
                        else
                        {
                 
                            str='Changed';
                            srtHistory.NewValue__c=sptObj.Prelim_Int_delivery_ask__c!=null?sptObj.Prelim_Int_delivery_ask__c.format():'';
                            srtHistory.Action__C=  str+' '+Schema.SD_Project_Tracking__c.fields.Prelim_Int_delivery_ask__c.getDescribe().getLabel() +' ' + ' to  ' + srtHistory.NewValue__c;
                            srtHistory.Field__c =  Schema.SD_Project_Tracking__c.fields.Prelim_Int_delivery_ask__c.getDescribe().getName(); 
                        }
                 
                        listOfHistory.add(srtHistory) ;
                    }
                    //Revised Final Delivery Ask
                    if( sptObj.Revised_Final_Delivery_ask__c!= oldMAp.Get(sptObj.id).Revised_Final_Delivery_ask__c){
                        SD_Resource_Tracking__c srtHistory=new SD_Resource_Tracking__c();
                        srtHistory.SD_Project_Tracking_History__c=sptObj.id;
                        srtHistory.Date__c=System.Now();            
                        srtHistory.User__c=userInfo.getUserId();
            
                        String oldvalue='';
                        String str='Changed';
                        if(oldMAp.Get(sptObj.id).Revised_Final_Delivery_ask__c!=null){
            
                            srtHistory.NewValue__c=sptObj.Revised_Final_Delivery_ask__c!=null?sptObj.Revised_Final_Delivery_ask__c.format():'';
                            srtHistory.OldValue__c=oldMAp.Get(sptObj.id).Revised_Final_Delivery_ask__c.format();
                            oldValue=oldMAp.Get(sptObj.id).Revised_Final_Delivery_ask__c.format();
                            if(sptObj.Revised_Final_Delivery_ask__c==null){
                                str='Deleted';
                                srtHistory.Action__C=str+' '+oldValue +' In '+Schema.SD_Project_Tracking__c.fields.Revised_Final_Delivery_ask__c.getDescribe().getLabel();  
                                srtHistory.Field__c =  Schema.SD_Project_Tracking__c.fields.Revised_Final_Delivery_ask__c.getDescribe().getName(); 
                            }
                            else
                            {
              
                                srtHistory.Action__C=str+' '+Schema.SD_Project_Tracking__c.fields.Revised_Final_Delivery_ask__c.getDescribe().getLabel() +' ' + ' From ' +oldValue + ' to ' + srtHistory.NewValue__c ; 
                                srtHistory.Field__c =  Schema.SD_Project_Tracking__c.fields.Revised_Final_Delivery_ask__c.getDescribe().getName();
                            }           
                        }
                        else
                        {
                 
                            str='Changed';
                            srtHistory.NewValue__c=sptObj.Revised_Final_Delivery_ask__c!=null?sptObj.Revised_Final_Delivery_ask__c.format():'';
                            srtHistory.Action__C=  str+' '+Schema.SD_Project_Tracking__c.fields.Revised_Final_Delivery_ask__c.getDescribe().getLabel() +' ' + ' to  ' + srtHistory.NewValue__c;
                            srtHistory.Field__c =  Schema.SD_Project_Tracking__c.fields.Revised_Final_Delivery_ask__c.getDescribe().getName();
                        }
                 
                        listOfHistory.add(srtHistory) ;
                    }
                    // System Design Re-Commit
                    if( sptObj.System_Design_Re_Commit__c!= oldMAp.Get(sptObj.id).System_Design_Re_Commit__c){
                        SD_Resource_Tracking__c srtHistory=new SD_Resource_Tracking__c();
                        srtHistory.SD_Project_Tracking_History__c=sptObj.id;
                        srtHistory.Date__c=System.Now();            
                        srtHistory.User__c=userInfo.getUserId();
            
                        String oldvalue='';
                        String str='Changed';
                        if(oldMAp.Get(sptObj.id).System_Design_Re_Commit__c!=null){
            
                            srtHistory.NewValue__c=sptObj.System_Design_Re_Commit__c!=null?sptObj.System_Design_Re_Commit__c:'';
                            srtHistory.OldValue__c=oldMAp.Get(sptObj.id).System_Design_Re_Commit__c;
                            oldValue=oldMAp.Get(sptObj.id).System_Design_Re_Commit__c;
                            if(sptObj.System_Design_Re_Commit__c==null){
                                str='Deleted';
                                srtHistory.Action__C=str+' '+oldValue +' In '+Schema.SD_Project_Tracking__c.fields.System_Design_Re_Commit__c.getDescribe().getLabel();    
                                srtHistory.Field__c =  Schema.SD_Project_Tracking__c.fields.System_Design_Re_Commit__c.getDescribe().getName();
                            }
                            else
                            {
              
                                srtHistory.Action__C=str+' '+Schema.SD_Project_Tracking__c.fields.System_Design_Re_Commit__c.getDescribe().getLabel() +' ' + ' From ' +oldValue + ' to ' + srtHistory.NewValue__c ; 
                                srtHistory.Field__c =  Schema.SD_Project_Tracking__c.fields.System_Design_Re_Commit__c.getDescribe().getName();
                            }           
                        }
                        else
                        {
                 
                            str='Changed';
                            srtHistory.NewValue__c=sptObj.System_Design_Re_Commit__c!=null?sptObj.System_Design_Re_Commit__c:'';
                            srtHistory.Action__C=  str+' '+Schema.SD_Project_Tracking__c.fields.System_Design_Re_Commit__c.getDescribe().getLabel() +' ' + ' to  ' + srtHistory.NewValue__c;
                            srtHistory.Field__c =  Schema.SD_Project_Tracking__c.fields.System_Design_Re_Commit__c.getDescribe().getName();
                        }
                        integer n=1;
                        System.Debug(n+'------>'+listOfHistory);  
                        n++; 
                        listOfHistory.add(srtHistory) ;
                    }
                }
            }
            System.Debug('------>'+listOfHistory.size());
            if(listOfHistory.size()>0){
                insert listOfHistory;
                System.Debug(listOfHistory);
            }
    } 

}