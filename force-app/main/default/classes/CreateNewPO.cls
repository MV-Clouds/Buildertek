public class CreateNewPO{
    @AuraEnabled
    public static String getobjectName(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();  
        return sObjName;
    }
	@AuraEnabled
	public static buildertek__Project__c getPOAddress(String recordId){
		List<buildertek__Project__c> projectRecs = [SELECT Id, Name, buildertek__Address__c, buildertek__Zip__c, buildertek__City__c, buildertek__Country__c, buildertek__State__c, buildertek__Ship_To_Account__c
		                                            FROM buildertek__Project__c
		                                            WHERE Id = :recordId
		                                            LIMIT 1];
		if (projectRecs.size() > 0){
			return projectRecs[0];
		}
		return null;
	}
    @AuraEnabled
	public static list<buildertek__Contract__c> contractdetails(String venderId){
        Date d = Date.ValueOf(System.today());
		List<buildertek__Contract__c> contractRecs = [SELECT Id, Name, buildertek__Contract_Start_Date__c, buildertek__Contract_End_Date__c,buildertek__Vendor__c,buildertek__Revised_Contract_Amount__c
		                                            FROM buildertek__Contract__c
		                                            WHERE buildertek__Contract__c.buildertek__Vendor__c  = :venderId AND (buildertek__Contract_Start_Date__c <= :d AND buildertek__Contract_End_Date__c > :d) AND buildertek__Type__c = 'Master'];
		if (contractRecs.size() > 0){
			return contractRecs;
		}
		return contractRecs;
	}
	@AuraEnabled 
	public static String saveNewPO(String recordId, String vender, String billToAddress, String description, String POtype, Date requiredDeliverydate, String shiptoAddress, String shiptoCity, String shiptoState, String shiptoCountry, String shiptoZip, String contractlinelist, string objName){

		buildertek__Purchase_Order__c po = new buildertek__Purchase_Order__c();
		//po.buildertek__Project__c = recordId;
		po.buildertek__Vendor__c = vender;
		po.buildertek__Bill_To_Address__c = billToAddress;
		po.buildertek__Description__c = description;
		po.buildertek__Required_Delivery_Date__c = requiredDeliverydate;
		po.buildertek__Type__c = POtype;
        po.buildertek__Status__c = 'Open';
		po.buildertek__ShipToAddress__c = shiptoAddress;
		po.buildertek__Ship_To_City__c = shiptoCity;
		po.buildertek__Ship_To_State__c = shiptoState;
		po.buildertek__Ship_To_Zip__c = shiptoZip;
		system.debug('shiptoCountry---->' + shiptoCountry);
		if (shiptoCountry != null){
			po.buildertek__Ship_To_Country__c = shiptoCountry;
		}
        if(objName == 'buildertek__Project__c'){
            po.buildertek__Project__c = recordId;
        }else if(objName == 'buildertek__RFQ__c'){
            po.buildertek__RFQ__c = recordId;
        }else if(objName == 'buildertek__Contract__c'){
            po.buildertek__Sub_Contract__c = recordId;
        }else if(objName == 'buildertek__Change_Order__c'){
            po.buildertek__Change_Order__c = recordId;
        }/*else if(objName == 'buildertek__Budget__c'){
            po.buildertek__Budget__c = recordId;
        }*/else if(objName == 'buildertek__Accounting_Period__c'){
           po.buildertek__Period__c = recordId;
        }else if(objName == 'buildertek__Service_Request__c'){
            po.buildertek__Service_Request__c = recordId;
        }else if(objName == 'buildertek__Project_Task__c'){
            po.buildertek__Schedule_Item__c = recordId;
        }else if(objName == 'buildertek__Quote__c'){
            po.buildertek__Quote__c = recordId;
        }else if(objName == 'buildertek__Cost_Codes__c'){
            po.buildertek__Cost_Code__c = recordId;
        }else if(objName == 'Contact'){
            po.buildertek__Contractor_Resource__c = recordId;
        }else if(objName == 'buildertek__Community__c'){
            po.buildertek__Community__c = recordId;
        }/*else if(objName == 'buildertek__Budget_Item__c'){
            po.buildertek__Budget_Line__c = recordId;
        }*/else if(objName == 'Account'){
            po.buildertek__Bill_To_Address__c = recordId;
        }
		insert po;
        system.debug('pooo'+po);
        List<buildertek__Contract_Item__c> contractitemlist = [Select id,Name,buildertek__Auto_Number__c,buildertek__Budget_Item__c,buildertek__Contract__c,buildertek__Contract_Line_Group__c,
                                                              buildertek__Cost_Code__c,buildertek__Description__c,buildertek__Discount__c,buildertek__Contract_Item_Group__c,buildertek__Item_Name__c,
                                                              buildertek__Product__c,buildertek__Quantity__c,buildertek__Reason_for_Change__c,buildertek__Unit_Price__c,buildertek__Total_Price__c 
                                                              from buildertek__Contract_Item__c Where buildertek__Contract__c = : contractlinelist];
        List<buildertek__Purchase_Order_Item__c> purchaseLineList= new List<buildertek__Purchase_Order_Item__c>();
        if(contractitemlist.size() > 0){
            for(buildertek__Contract_Item__c contractRec : contractitemlist){
                buildertek__Purchase_Order_Item__c POIRec = new buildertek__Purchase_Order_Item__c();
                POIRec.buildertek__Purchase_Order__c = po.Id;
                POIRec.buildertek__Budget_Item__c = contractRec.buildertek__Budget_Item__c;
                POIRec.buildertek__Cost_Code__c = contractRec.buildertek__Cost_Code__c;
                POIRec.buildertek__Description__c = contractRec.buildertek__Description__c;
                POIRec.buildertek__Discount__c = contractRec.buildertek__Discount__c;
                POIRec.buildertek__Item_Name__c = contractRec.buildertek__Item_Name__c;
                POIRec.buildertek__Product__c  = contractRec.buildertek__Product__c;
                POIRec.buildertek__Quantity__c = contractRec.buildertek__Quantity__c;
                POIRec.buildertek__Unit_Price__c = contractRec.buildertek__Unit_Price__c;
                POIRec.Name = contractRec.Name;
                purchaseLineList.add(POIRec);
            } 
        }
        if(purchaseLineList.size()>0){
            insert purchaseLineList;
        }
		system.debug('Purchase_Order::' + po);
		return po.Id;
	}
}