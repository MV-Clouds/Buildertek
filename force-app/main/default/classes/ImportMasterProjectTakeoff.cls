public with sharing class ImportMasterProjectTakeoff{
	@AuraEnabled
	public static object getMasterProjectTakeoff(String recordId){
		list<buildertek__Project_Takeoff__c> masterProjecttakeofflst;

		masterProjecttakeofflst = [SELECT Id, Name, buildertek__Community__c, buildertek__Community__r.Name, buildertek__Project__c, buildertek__Project__r.Name, buildertek__Type__c, buildertek__Plan_Type__c
		                           FROM buildertek__Project_Takeoff__c
		                           WHERE buildertek__Type__c = 'Master' AND ID != :recordId];


		List<MasterProjectTakeoffClass> MasterProjectTakeoffClassList = new List<MasterProjectTakeoffClass>();
		for (buildertek__Project_Takeoff__c masterptakeoff : masterProjecttakeofflst){
			MasterProjectTakeoffClass MasterProjectTakeoffClassRecord = new MasterProjectTakeoffClass();
			MasterProjectTakeoffClassRecord.masterprojecttakeoffrecord = masterptakeoff;
			MasterProjectTakeoffClassRecord.projecttakeoffCheck = false;
			MasterProjectTakeoffClassList.add(MasterProjectTakeoffClassRecord);
		}
		return MasterProjectTakeoffClassList;
	}

	@AuraEnabled
	public static MessageClass importMasterProjecttakeoffLines(List<String> takeofflIds, String recordId){
		MessageClass msg = new MessageClass();
		try{
			List<buildertek__Project_Takeoff_Lines__c> takeoffitemslst;

			takeoffitemslst = [SELECT Id, Name, buildertek__Description__c, buildertek__Location__c, buildertek__Quantity__c, buildertek__Sq_Ft__c, buildertek__Category__c, buildertek__Scale__c, buildertek__Project_Takeoff__c, buildertek__Plan_Type__c, buildertek__Trade_Type__c, buildertek__Product_Type__c, buildertek__Categories__c, buildertek__UOM__c
			                   FROM buildertek__Project_Takeoff_Lines__c
			                   WHERE buildertek__Project_Takeoff__c IN :takeofflIds];


			List<buildertek__Project_Takeoff_Lines__c> takeoffitemsToinsertlst = new List<buildertek__Project_Takeoff_Lines__c>();


			if (!takeoffitemslst.isEmpty()){
				for (buildertek__Project_Takeoff_Lines__c takeoffitem : takeoffitemslst){
					buildertek__Project_Takeoff_Lines__c projecttakeoffItemToInsert = new buildertek__Project_Takeoff_Lines__c();

					projecttakeoffItemToInsert.buildertek__Description__c = takeoffitem.buildertek__Description__c;
					projecttakeoffItemToInsert.buildertek__Location__c = takeoffitem.buildertek__Location__c;
					projecttakeoffItemToInsert.buildertek__Quantity__c = takeoffitem.buildertek__Quantity__c;
					projecttakeoffItemToInsert.buildertek__Sq_Ft__c = takeoffitem.buildertek__Sq_Ft__c;
					projecttakeoffItemToInsert.buildertek__Category__c = takeoffitem.buildertek__Category__c;
					projecttakeoffItemToInsert.buildertek__Scale__c = takeoffitem.buildertek__Scale__c;
					projecttakeoffItemToInsert.buildertek__Project_Takeoff__c = recordId;
					projecttakeoffItemToInsert.buildertek__Plan_Type__c = takeoffitem.buildertek__Plan_Type__c;
					projecttakeoffItemToInsert.buildertek__Trade_Type__c = takeoffitem.buildertek__Trade_Type__c;
					projecttakeoffItemToInsert.buildertek__Product_Type__c = takeoffitem.buildertek__Product_Type__c;
					projecttakeoffItemToInsert.buildertek__Categories__c = takeoffitem.buildertek__Categories__c;
					projecttakeoffItemToInsert.buildertek__UOM__c = takeoffitem.buildertek__UOM__c;


					takeoffitemsToinsertlst.add(projecttakeoffItemToInsert);
				}
			}
			if (takeoffitemsToinsertlst.size() > 0){

				insert takeoffitemsToinsertlst;

				msg.Status = 'Success';
				msg.Message = 'Project Takeoff Lines Imported Successfully';
			} else{
				msg.Status = 'Failed';
				msg.Message = 'There were no Project Takeoff Lines for the selected Project Takeoff';
			}
			return msg;
		} catch (Exception exp){
			msg.Status = 'Failed';
			msg.Message = exp.getMessage();
			return msg;
		}
	}

	public class MasterProjectTakeoffClass{
		@AuraEnabled
		public buildertek__Project_Takeoff__c masterprojecttakeoffrecord{ get; set; }

		@AuraEnabled
		public boolean projecttakeoffCheck{ get; set; }
	}

	public class MessageClass{
		@AuraEnabled
		public String Status{ get; set; }

		@AuraEnabled
		public string Message{ get; set; }
	}
}