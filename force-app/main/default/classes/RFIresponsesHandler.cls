public class RFIresponsesHandler {
    
    public static void test(){
        system.debug('test');
    }
    
    public static void insertrfiresponse(list<buildertek__RFI_Response__c> rfiresponselist){
        // Set<Id> rfiidSet = new Set<Id>();
        List<buildertek__RFI__c> updaterfilist = new List<buildertek__RFI__c>();
        List<buildertek__RFI__c> rfiList = new List<buildertek__RFI__c>();
        Map<id,id> responserfimap = new Map<id,id>();
        Map<id,buildertek__RFI__c > maprfi= new Map<id,buildertek__RFI__c>();
        List<id> rfiid = new List<id>();
        for(buildertek__RFI_Response__c rfiresponse: rfiresponselist){
            system.debug(rfiresponse.buildertek__Response_From_CMP__c);
            if(rfiresponse.buildertek__Response_From_CMP__c == false ){
                BT_New_RFI_Controller.updateRFQ(rfiresponse.Id,null,null,null);
            }            
            rfiid.add(rfiresponse.buildertek__RFI__c);
            responserfimap.put(rfiresponse.id,rfiresponse.buildertek__RFI__c);
        }
        rfiList = [select id,buildertek__Last_Responded_By__c,buildertek__Last_Responded_Date__c from buildertek__RFI__c where id in:rfiid];
        system.debug( 'rfiList'+ rfiList);
        if(rfiList.size()>0){
            for(buildertek__RFI__c rfirecord:rfiList){
                maprfi.put(rfirecord.id,rfirecord);
            }
        }
        system.debug('maprfi'+maprfi);
        for(buildertek__RFI_Response__c rfiresponserec: rfiresponselist){
            buildertek__RFI__c rfirec = maprfi.get(responserfimap.get(rfiresponserec.id));
            system.debug('rfirec'+rfirec);
            if(rfirec != Null){
                rfirec.buildertek__Last_Responded_By__c = rfiresponserec.buildertek__Responder__c;
                rfirec.buildertek__Last_Responded_Date__c = date.Today();
                updaterfilist.add(rfirec);
            }
        }
        system.debug('updaterfilist'+ updaterfilist);
        if(updaterfilist.size()>0){
            database.update(updaterfilist);
        }                         
        
    }
    public static void updaterfiresponse(list<buildertek__RFI_Response__c> rfiresponselists){
        List<buildertek__RFI__c> Updaterfi = new List<buildertek__RFI__c>();
        List<buildertek__RFI__c> UpdaterfiList = new List<buildertek__RFI__c>();
        Map<id,id> Updateresponserfimap = new Map<id,id>();
        Map<id,buildertek__RFI__c > Updatemaprfi= new Map<id,buildertek__RFI__c>();
        List<id> Updaterfiid = new List<id>();
        for(buildertek__RFI_Response__c rfiresponse: rfiresponselists){
            Updaterfiid.add(rfiresponse.buildertek__RFI__c);
            Updateresponserfimap.put(rfiresponse.id,rfiresponse.buildertek__RFI__c);
        }
        UpdaterfiList = [select id,buildertek__Last_Responded_By__c,buildertek__Last_Responded_Date__c from buildertek__RFI__c where id in:Updaterfiid];
        system.debug( 'UpdaterfiList'+ UpdaterfiList);
        if(UpdaterfiList.size()>0){
            for(buildertek__RFI__c rfirecord:UpdaterfiList){
                Updatemaprfi.put(rfirecord.id,rfirecord);
            }
        }
        system.debug('Updatemaprfi'+ Updatemaprfi);
        for(buildertek__RFI_Response__c rfiresponserec: rfiresponselists){
            buildertek__RFI__c rfirec = Updatemaprfi.get(Updateresponserfimap.get(rfiresponserec.id));
            system.debug('rfirec'+rfirec);
            if(rfirec != Null){
                rfirec.buildertek__Last_Responded_By__c = rfiresponserec.buildertek__Responder__c;
                rfirec.buildertek__Last_Responded_Date__c = date.Today();
                updaterfi.add(rfirec);
            }
        }
        system.debug('updaterfi'+ updaterfi);
        if(updaterfi.size()>0){
            database.update(updaterfi);
        }
        
        
    }
  
        public static void deleterfiresponse(list<buildertek__RFI_Response__c> rfiresponse){
            List<id> deleterfilist = new List<id>();
            List<buildertek__RFI__c> newrfilist = new  List<buildertek__RFI__c>();
            list<buildertek__RFI_Response__c> rfiList = new list<buildertek__RFI_Response__c>();
            list<buildertek__RFI__c> rfilistupdate=new list<buildertek__RFI__c>();
            List<buildertek__RFI__c> rfiswithemptyRfiResponses = new List<buildertek__RFI__c>();
            Map<id,List<buildertek__RFI_Response__c>> deleteresponse = new Map<id,List<buildertek__RFI_Response__c>>();
            Map<id,id> responserfmap=new map<id,id>();
            Map<id,buildertek__RFI__c> rfiidmap=new Map<id,buildertek__RFI__c>();
            for(buildertek__RFI_Response__c rfiresponserecord:rfiresponse){
                deleterfilist.add(rfiresponserecord.buildertek__RFI__c);
                responserfmap.put(rfiresponserecord.id,rfiresponserecord.buildertek__RFI__c);
                system.debug('rfiresponserecord'+rfiresponserecord);
            }
            system.debug('responserfmap'+responserfmap);
            if(deleterfilist.size()>0){
                rfiList=[select id,buildertek__Response__c,buildertek__Responder__c,createddate,buildertek__RFI__c from buildertek__RFI_Response__c where buildertek__RFI__c in:deleterfilist Order by createddate desc];
                system.debug('rfiList'+rfiList);
                //newrfilist=[select id,buildertek__Last_Responded_By__c,buildertek__Last_Responded_Date__c from buildertek__RFI__c where id in:deleterfilist];
                newrfilist=[select id,buildertek__Last_Responded_By__c,buildertek__Last_Responded_Date__c,(select Id from buildertek__RFI_Responses__r) from buildertek__RFI__c where id in:deleterfilist];
                system.debug('newrfilist'+newrfilist);
                for (buildertek__RFI__c u :newrfilist ) {
                    buildertek__RFI__c newrfi = new buildertek__RFI__c();
                    if(u.buildertek__RFI_Responses__r.size() == 0){
                        newrfi.Id = u.Id;
                        newrfi.buildertek__Last_Responded_By__c = null;
                        newrfi.buildertek__Last_Responded_Date__c = null;
                        rfiswithemptyRfiResponses.add(newrfi);
                    }
                    
                    
                    
                }
            }
            if(newrfilist.size()>0){
                for(buildertek__RFI__c rfirec:newrfilist){
                    rfiidmap.put(rfirec.id,rfirec);
                    system.debug('rfiidmap'+rfiidmap);
                }
            }
            
            if(rfiList.size()>0){
                for( buildertek__RFI_Response__c onrfiresponserec : rfiList){
                    if(deleteresponse.get(onrfiresponserec.buildertek__RFI__c)!=null){
                        list<buildertek__RFI_Response__c> onrfiList = deleteresponse.get(onrfiresponserec.buildertek__RFI__c);
                        onrfiList.add(onrfiresponserec);    
                        deleteresponse.put(onrfiresponserec.buildertek__RFI__c,onrfiList); 
                        system.debug('deleteresponse'+deleteresponse);
                    }else{
                        list<buildertek__RFI_Response__c> onrfirec = new list<buildertek__RFI_Response__c>();
                        onrfirec.add(onrfiresponserec);
                        deleteresponse.put(onrfiresponserec.buildertek__RFI__c,onrfirec); 
                        system.debug('deleteresponse'+deleteresponse);
                    }
                }
            }
            for(buildertek__RFI_Response__c rfiresponserecord:rfiresponse){
                if(rfiresponserecord.buildertek__RFI__c!=null){
                    if(deleteresponse.get(rfiresponserecord.buildertek__RFI__c)!=null){
                        list<buildertek__RFI_Response__c> onrfiresList = deleteresponse.get(rfiresponserecord.buildertek__RFI__c);
                        buildertek__RFI_Response__c mostrecentrfirec = onrfiresList[0];
                        system.debug('mostrecentrfirec'+ mostrecentrfirec);
                        system.debug(rfiidmap);
                        system.debug(responserfmap.get(mostrecentrfirec.Id));
                        //buildertek__RFI__c recrfi=rfiidmap.get(responserfmap.get(mostrecentrfirec.Id));
                        buildertek__RFI__c recrfi=rfiidmap.get(mostrecentrfirec.buildertek__RFI__c);
                        system.debug('recrfi'+recrfi);
                        if(recrfi!=null){
                            recrfi.buildertek__Last_Responded_By__c = mostrecentrfirec.buildertek__Responder__c;
                            recrfi.buildertek__Last_Responded_Date__c = date.Today();
                            rfilistupdate.add(recrfi);
                            system.debug('rfilistupdate'+rfilistupdate);
                        }
                        else{
                            recrfi.buildertek__Last_Responded_Date__c = null;
                            rfilistupdate.add(recrfi);
                            
                        }
                        
                    }
                }
            }
            system.debug('rfilistupdate'+rfilistupdate);
            if(rfilistupdate.size()>0){
                Database.update(rfilistupdate);
                
            }
            if(rfiswithemptyRfiResponses.size() > 0){
                update rfiswithemptyRfiResponses;
            }
            
        }
    
    public static void Beforeinsertrfiresponse(list<buildertek__RFI_Response__c> rfiresponselist){
        List<buildertek__RFI__c> rfilist = new List<buildertek__RFI__c>();
        List<id> rfiid = new List<id>();
        Map<id,buildertek__RFI__c > maprfi= new Map<id,buildertek__RFI__c>();
        
        for(buildertek__RFI_Response__c rfiresponse: rfiresponselist){
            rfiid.add(rfiresponse.buildertek__RFI__c);
        }
        
        rfiList = [select id, buildertek__Status__c from buildertek__RFI__c where id in:rfiid];
        if(rfiList.size()>0){
            for(buildertek__RFI__c rfirecord:rfiList){
                maprfi.put(rfirecord.id,rfirecord);
            }
        }
        
        for(buildertek__RFI_Response__c rfiresponserec: rfiresponselist){
            buildertek__RFI__c rfirec = maprfi.get(rfiresponserec.buildertek__RFI__c);
            if(rfirec.buildertek__Status__c=='Closed'){
                rfiresponserec.addError('You cannot respond to this RFI because this RFI is already Closed.');
            }
            rfiresponserec.buildertek__Answered__c = 'Yes';
            rfiresponserec.buildertek__Response_Date__c = system.today();
        }
    }
}