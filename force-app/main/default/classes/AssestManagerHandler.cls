public with sharing class AssestManagerHandler{
	public static Boolean blnSkipAssetHistoryTrigger = false;
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	public AssestManagerHandler(boolean isExecuting, integer size){
        system.debug('&&&&&&&&&&');
        m_isExecuting = isExecuting;
		BatchSize = size;
	}

	public void OnBeforeInsert(List<buildertek__Asset_History__c> assetHistory){
		Map<Id, buildertek__Asset_History__c> assetHistories = new Map<Id, buildertek__Asset_History__c>();
		for (buildertek__Asset_History__c record : assetHistory){
			assetHistories.put(record.buildertek__Asset_Manager__c, record);
		}

		List<buildertek__Asset_History__c> recordList = [Select Id, Name, buildertek__Asset_Manager__c, buildertek__Date_on_Job__c, buildertek__Date_off_Job__c
		                                                 FROM buildertek__Asset_History__c
		                                                 WHERE buildertek__Asset_Manager__c In :assetHistories.keySet()
		                                                 ORDER by CreatedDate DESC];

		Map<Id, buildertek__Asset_History__c> assetMap = new Map<Id, buildertek__Asset_History__c>();
		for (buildertek__Asset_History__c assets : recordList){
			if (!assetMap.containsKey(assets.buildertek__Asset_Manager__c)){
				assetMap.put(assets.buildertek__Asset_Manager__c, assets);
			}
		}

		if (recordList.size() > 0){
			for (buildertek__Asset_History__c record : assetHistories.values()){
				if (record.buildertek__Asset_Manager__c == assetMap.get(record.buildertek__Asset_Manager__c).buildertek__Asset_Manager__c){
					record.buildertek__Date_on_Job__c = assetMap.get(record.buildertek__Asset_Manager__c).buildertek__Date_off_Job__c;
				}
			}
		}
	}

    public void afterInsert(List<buildertek__Asset_History__c> newAssetHistory, Map<Id, buildertek__Asset_History__c> AssetHistoryMap){
        list<Id> assetManagerId = new list<Id>();
        List<buildertek__Asset_Manager__c> assetManagerList = new List<buildertek__Asset_Manager__c>();
        
        for(buildertek__Asset_History__c assetHistory : newAssetHistory){
            assetManagerId.add(assetHistory.buildertek__Asset_Manager__c);
        }
        if (assetManagerId.size() > 0){
            assetManagerList = [Select Id, Name,buildertek__Current_Project__c,buildertek__Location_on_Jobsite__c
                               FROM buildertek__Asset_Manager__c
                               WHERE Id IN :assetManagerId];
        }

        for (buildertek__Asset_Manager__c assetmanagerRec: assetManagerList){
            for (buildertek__Asset_History__c assethistoryRec : newAssetHistory){
                assetmanagerRec.buildertek__Current_Project__c = assethistoryRec.buildertek__Project__c;
                assetmanagerRec.buildertek__Location_on_Jobsite__c = assethistoryRec.buildertek__Location_on_Jobsite__c;
            }
        }
        update assetManagerList;
}

 	public void afterUpdate(List<buildertek__Asset_History__c> newAssetHistory, List<buildertek__Asset_History__c> oldAssetHistry, Map<Id, buildertek__Asset_History__c> NewAssHisMap, Map<Id, buildertek__Asset_History__c> oldAssHisMap){
		
// ----------------------- Update Asset Record When most recent Asset History is Updated --------------- BUIL - 3452 ---------------------------------------------------
		// try {
		system.debug('Inside After Update');
		Set<Id> assetManagerIdSet = new Set<Id>();
		List<buildertek__Asset_Manager__c> AssManListToUpDate = new List<buildertek__Asset_Manager__c>();
		Map<Id, buildertek__Asset_History__c> AssMap = new Map<Id, buildertek__Asset_History__c>();

		for(buildertek__Asset_History__c UpdatedAH : newAssetHistory){
			buildertek__Asset_History__c RecentAH = [SELECT Id,Name, buildertek__Asset_Manager__c, buildertek__Project__c, buildertek__Location_on_Jobsite__c FROM buildertek__Asset_History__c WHERE buildertek__Asset_Manager__c =: UpdatedAH.buildertek__Asset_Manager__c ORDER BY CreatedDate DESC LIMIT 1];

			// Check If Updated "Asset Histry" is recent "Asset Histry" of a "Perticular Asset" -- If Yes Then Update Asset.
			if(UpdatedAH.Id == RecentAH.Id){
				if(UpdatedAH.buildertek__Project__c != oldAssHisMap.get(UpdatedAH.Id).buildertek__Project__c || UpdatedAH.buildertek__Location_on_Jobsite__c != oldAssHisMap.get(UpdatedAH.Id).buildertek__Location_on_Jobsite__c){
					buildertek__Asset_Manager__c AssMan = new buildertek__Asset_Manager__c(Id = UpdatedAH.buildertek__Asset_Manager__c);
					AssMan.buildertek__Current_Project__c = RecentAH.buildertek__Project__c;
					AssMan.buildertek__Location_on_Jobsite__c = RecentAH.buildertek__Location_on_Jobsite__c;
					AssManListToUpDate.add(AssMan);
					//	 System.debug('Recent AH is Updted');
				}
			}
		}
		if(AssManListToUpDate.size() > 0){
			// System.debug('Going To Update Asset ===>> ' + AssManListToUpDate);
			update AssManListToUpDate;
		}
		// } catch (Exception e) {
		// 	System.debug('Error in After Update =::: '+ e.getMessage() +' -- '+ e.getStackTraceString());
		// } 
		// =============================================== End ==================================================================
 }

 public void beforeDelete(List<buildertek__Asset_History__c> newAssetHistory, List<buildertek__Asset_History__c> oldAssetHistry, Map<Id, buildertek__Asset_History__c> NewAssHisMap, Map<Id, buildertek__Asset_History__c> oldAssHisMap){

	// ----------------------- Update Asset Record When most recent Asset History is Deleted --------------- BUIL - 3452 ---------------------------------------------------
		// try {
			system.debug('Inside After Update');
			Set<Id> assetManagerIdSet = new Set<Id>();
			List<buildertek__Asset_Manager__c> AssManListToUpDate = new List<buildertek__Asset_Manager__c>();
			Map<Id, buildertek__Asset_History__c> AssMap = new Map<Id, buildertek__Asset_History__c>();
	
			for(buildertek__Asset_History__c DeletedAH : oldAssetHistry){
				list<buildertek__Asset_History__c> RecentAH = [SELECT Id,Name, buildertek__Asset_Manager__c, buildertek__Project__c, buildertek__Location_on_Jobsite__c FROM buildertek__Asset_History__c WHERE buildertek__Asset_Manager__c =: DeletedAH.buildertek__Asset_Manager__c ORDER BY CreatedDate DESC];

				// Check if Most Recent Asset history is Delted -----> If Yes Then --> Update Asset with new most Recent(Second most recent) Assest History
				if(RecentAH.size() > 1 && DeletedAH.Id == RecentAH[0].Id){
					buildertek__Asset_Manager__c AssMan = new buildertek__Asset_Manager__c(Id = DeletedAH.buildertek__Asset_Manager__c);
					AssMan.buildertek__Current_Project__c = RecentAH[1].buildertek__Project__c;
					AssMan.buildertek__Location_on_Jobsite__c = RecentAH[1].buildertek__Location_on_Jobsite__c;
					AssManListToUpDate.add(AssMan);
					// system.debug('Most recent Histoy Is Deleted and Update with second Most History');
				}
				else if(RecentAH.size() <= 1){ // --> When Only one asset history is availabe
					buildertek__Asset_Manager__c AssMan = new buildertek__Asset_Manager__c(Id = DeletedAH.buildertek__Asset_Manager__c);
					AssMan.buildertek__Current_Project__c = null;
					AssMan.buildertek__Location_on_Jobsite__c = null;
					AssManListToUpDate.add(AssMan);
					// system.debug('Most recent Histoy Is Deleted and There is no More History Pending');
				}
			}
			if(AssManListToUpDate.size() > 0){
				update AssManListToUpDate;
			}
		// } catch (Exception e) {
		// 	System.debug('Error in After Update =::: '+ e.getMessage() +' -- '+ e.getStackTraceString());
		// } 
		// =============================================== End ==================================================================
			
 }

	public void beforeInsert(List<buildertek__Asset_History__c> newAssetHistory){

		String budgetLineGroupId ;
		List<buildertek__Budget_Line_Group__c> budgetLineGroups = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c WHERE Name = 'No Grouping' LIMIT 1];
		if(budgetLineGroups.size() == 0){
			buildertek__Budget_Line_Group__c budgetLineGroup = new buildertek__Budget_Line_Group__c();
			budgetLineGroup.Name = 'No Grouping';
			insert budgetLineGroup;
			budgetLineGroupId = budgetLineGroup.Id;
		}else{
			budgetLineGroupId = budgetLineGroups[0].Id;
		}

		List<buildertek__Budget_Item__c> budgetLines = new List<buildertek__Budget_Item__c>();
		for(buildertek__Asset_History__c assetHistory : newAssetHistory){
			if(assetHistory.buildertek__BT_Budget__c != null && assetHistory.buildertek__BT_Budget_Line__c == null){
				buildertek__Budget_Item__c budgetLine = new buildertek__Budget_Item__c();
				budgetLine.Name = assetHistory.Name;
				budgetLine.buildertek__Budget__c = assetHistory.buildertek__BT_Budget__c;
				budgetLine.buildertek__Group__c = budgetLineGroupId;
				budgetLines.add(budgetLine);
			}
		}
		if(budgetLines.size() > 0){
			insert budgetLines;
		}

		for(buildertek__Asset_History__c assetHistory : newAssetHistory){
			if(assetHistory.buildertek__BT_Budget__c != null && assetHistory.buildertek__BT_Budget_Line__c == null){
				for(buildertek__Budget_Item__c budgetLine : budgetLines){
					if(budgetLine.buildertek__Budget__c == assetHistory.buildertek__BT_Budget__c && budgetLine.Name == assetHistory.Name){
						assetHistory.buildertek__BT_Budget_Line__c = budgetLine.Id;
					}
				}
			}
		}
	}

	public void afterInsert(List<buildertek__Asset_History__c> newAssetHistory){
		List<Id> budgetLineIds = new List<Id>();
		for(buildertek__Asset_History__c assetHistory : newAssetHistory){
			if(assetHistory.buildertek__BT_Budget_Line__c != null){
				budgetLineIds.add(assetHistory.buildertek__BT_Budget_Line__c);
			}
		}
		if(budgetLineIds.size() > 0){
			recalculateBudgetLine(budgetLineIds);
		}
	}

	public void beforeUpdate(List<buildertek__Asset_History__c> newAssetHistory, Map<Id, buildertek__Asset_History__c> oldAssetHistry){
		String budgetLineGroupId ;
		List<buildertek__Budget_Line_Group__c> budgetLineGroups = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c WHERE Name = 'No Grouping' LIMIT 1];
		if(budgetLineGroups.size() == 0){
			buildertek__Budget_Line_Group__c budgetLineGroup = new buildertek__Budget_Line_Group__c();
			budgetLineGroup.Name = 'No Grouping';
			insert budgetLineGroup;
			budgetLineGroupId = budgetLineGroup.Id;
		}else{
			budgetLineGroupId = budgetLineGroups[0].Id;
		}

		List<buildertek__Budget_Item__c> budgetLines = new List<buildertek__Budget_Item__c>();
		for(buildertek__Asset_History__c assetHistory : newAssetHistory){
			if(assetHistory.buildertek__BT_Budget__c != null && assetHistory.buildertek__BT_Budget_Line__c == null){
				buildertek__Asset_History__c oldAsset = oldAssetHistry.get(assetHistory.Id);
				if(oldAsset != null && oldAsset.buildertek__BT_Budget__c == null){
					buildertek__Budget_Item__c budgetLine = new buildertek__Budget_Item__c();
					budgetLine.Name = assetHistory.Name;
					budgetLine.buildertek__Budget__c = assetHistory.buildertek__BT_Budget__c;
					budgetLine.buildertek__Group__c = budgetLineGroupId;
					budgetLines.add(budgetLine);
				}
			}
		}
		if(budgetLines.size() > 0){
			insert budgetLines;
		}

		for(buildertek__Asset_History__c assetHistory : newAssetHistory){
			if(assetHistory.buildertek__BT_Budget__c != null && assetHistory.buildertek__BT_Budget_Line__c == null){
				for(buildertek__Budget_Item__c budgetLine : budgetLines){
					if(budgetLine.buildertek__Budget__c == assetHistory.buildertek__BT_Budget__c && budgetLine.Name == assetHistory.Name){
						assetHistory.buildertek__BT_Budget_Line__c = budgetLine.Id;
					}
				}
			}
		}

		Map<Id, buildertek__Asset_History__c> assetHistoryMap = new Map<Id, buildertek__Asset_History__c>();
		for(buildertek__Asset_History__c assetHistory : newAssetHistory){
			buildertek__Asset_History__c oldAssetHistory = oldAssetHistry.get(assetHistory.Id);
			if(oldAssetHistory != null && oldAssetHistory.buildertek__BT_Budget_Line__c != null && assetHistory.buildertek__BT_Budget_Line__c == null){
				assetHistory.buildertek__BT_Budget__c = null;
				assetHistoryMap.put(oldAssetHistory.buildertek__BT_Budget_Line__c, assetHistory);
			}

		}

		List<buildertek__Budget_Item__c> budgetItems = [SELECT Id, Name, buildertek__Budget__c, buildertek__Assets__c FROM buildertek__Budget_Item__c WHERE Id IN :assetHistoryMap.keySet()];

		List<buildertek__Budget_Item__c> toDeleteBL = new List<buildertek__Budget_Item__c>();
		List<buildertek__Budget_Item__c> toUpdateBL = new List<buildertek__Budget_Item__c>();

		for(buildertek__Budget_Item__c budgetItem : budgetItems){
			buildertek__Asset_History__c assetHistory = assetHistoryMap.get(budgetItem.Id);
			if(budgetItem.Name == assetHistory.Name){
				toDeleteBL.add(budgetItem);
			}else{
				budgetItem.buildertek__Assets__c = budgetItem.buildertek__Assets__c - assetHistory.buildertek__Cost__c;
				toUpdateBL.add(budgetItem);
			}
		}

		if(toDeleteBL.size() > 0 && blnSkipAssetHistoryTrigger == false){
			delete toDeleteBL;
		}

		if(toUpdateBL.size() > 0){
			update toUpdateBL;
		}
	}

	public void afterUpdate(List<buildertek__Asset_History__c> newAssetHistory){
		List<Id> budgetLineIds = new List<Id>();
		for(buildertek__Asset_History__c assetHistory : newAssetHistory){
			if(assetHistory.buildertek__BT_Budget_Line__c != null){
				budgetLineIds.add(assetHistory.buildertek__BT_Budget_Line__c);
			}
		}
		if(budgetLineIds.size() > 0){
			recalculateBudgetLine(budgetLineIds);
		}
	}

	public void beforeDelete(List<buildertek__Asset_History__c> newAssetHistory){
		Map<Id, buildertek__Asset_History__c> assetHistoryMap = new Map<Id, buildertek__Asset_History__c>();
		for(buildertek__Asset_History__c assetHistory : newAssetHistory){
			assetHistoryMap.put(assetHistory.Id, assetHistory);
		}

		List<buildertek__Budget_Item__c> budgetItems = [SELECT Id, Name, buildertek__Budget__c, buildertek__Assets__c FROM buildertek__Budget_Item__c WHERE Id IN :assetHistoryMap.keySet()];

		List<buildertek__Budget_Item__c> toDeleteBL = new List<buildertek__Budget_Item__c>();
		List<buildertek__Budget_Item__c> toUpdateBL = new List<buildertek__Budget_Item__c>();

		for(buildertek__Budget_Item__c budgetItem : budgetItems){
			buildertek__Asset_History__c assetHistory = assetHistoryMap.get(budgetItem.Id);
			if(budgetItem.Name == assetHistory.Name){
				toDeleteBL.add(budgetItem);
			}else{
				budgetItem.buildertek__Assets__c = budgetItem.buildertek__Assets__c - assetHistory.buildertek__Cost__c;
				toUpdateBL.add(budgetItem);
			}
		}

		if(toDeleteBL.size() > 0 && blnSkipAssetHistoryTrigger == false){
			delete toDeleteBL;
		}

		if(toUpdateBL.size() > 0){
			update toUpdateBL;
		}
	}

	public static void recalculateBudgetLine(List<Id> budgetLineIds){

		List<buildertek__Asset_History__c> assetHistories = [SELECT Id, Name, buildertek__BT_Budget_Line__c, buildertek__Cost__c FROM buildertek__Asset_History__c WHERE buildertek__BT_Budget_Line__c IN :budgetLineIds];

		Map<Id, Decimal> budgetLineCostMap = new Map<Id, Decimal>();
		for(buildertek__Asset_History__c assetHistory : assetHistories){
			if(budgetLineCostMap.containsKey(assetHistory.buildertek__BT_Budget_Line__c)){
				budgetLineCostMap.put(assetHistory.buildertek__BT_Budget_Line__c, budgetLineCostMap.get(assetHistory.buildertek__BT_Budget_Line__c) + assetHistory.buildertek__Cost__c);
			}else{
				budgetLineCostMap.put(assetHistory.buildertek__BT_Budget_Line__c, assetHistory.buildertek__Cost__c);
			}
		}

		List<buildertek__Budget_Item__c> budgetItems = new List<buildertek__Budget_Item__c>();
		for(Id budgetLineId : budgetLineCostMap.keySet()){
			buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c(Id = budgetLineId);
			budgetItem.buildertek__Assets__c = budgetLineCostMap.get(budgetLineId);
			budgetItems.add(budgetItem);
		}

		if(budgetItems.size() > 0){
			update budgetItems;
		}
		
	}



}