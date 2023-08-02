public with sharing class CreateTakeOffPackage{
	@AuraEnabled
	public static object getPackageTakeoff(){
		List<buildertek__Package__c> packageList = [SELECT Id, Name, buildertek__Package_Name__c,buildertek__Type__c
		                                            FROM buildertek__Package__c where buildertek__Type__c = 'Master'];

		List<ProjectClass> projectClassWrapperList = new List<ProjectClass>();
		for (buildertek__Package__c masterTakeOff : packageList){
			ProjectClass projectClassWrapper = new ProjectClass();
			projectClassWrapper.packageRecord = masterTakeOff;
			projectClassWrapper.packageTakeOffCheck = false;
			projectClassWrapperList.add(projectClassWrapper);
		}
		return projectClassWrapperList;
	}

	@AuraEnabled
	public static PackageLinesClass getPackageTakeoffRecords(List<String> takeOffLinesIds, String recordId, Integer pageNumber, Integer pageSize, String packageLinesSearchTradeType, String packageLinesSearchCategory, String packageLinesSearchProductType, String searchTradeType, String searchCategory, String searchProductType){
		try{
			PackageLinesClass packageLinesWrapper = new PackageLinesClass();
			//Base Query for TakeOff Lines
			String query = '';
			String filter = '';
			String baseFilter = '';
			Integer offset = (pageNumber - 1) * pageSize;//For TakeOff Lines
			Boolean isFieldExist = false;
			//Retrieve Project TakeOff - Top View.
			packageLinesWrapper.projectTakeOffRec = getProjectTakeOffRec(recordId);

			//Package Lines Search Filter
			query = 'SELECT Id, Name, buildertek__Category__c, buildertek__Category__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name, buildertek__Quantity__c, buildertek__UOM__c, buildertek__Location__c, buildertek__Product_Type__c, buildertek__Product_Type__r.Name, buildertek__Package_Name__c FROM buildertek__Package_Line__c WHERE';
			baseFilter = ' buildertek__Package_Name__c IN :takeOffLinesIds';
			if (String.isNotBlank(packageLinesSearchCategory)){
				packageLinesSearchCategory = '%' + packageLinesSearchCategory + '%';
				baseFilter += ' AND buildertek__Category__r.Name LIKE :packageLinesSearchCategory';
			}
			if (String.isNotBlank(packageLinesSearchTradeType)){
				packageLinesSearchTradeType = '%' + packageLinesSearchTradeType + '%';
				baseFilter += ' AND buildertek__Trade_Type__r.Name LIKE :packageLinesSearchTradeType';
			}
			if (String.isNotBlank(packageLinesSearchProductType)){
				packageLinesSearchProductType = '%' + packageLinesSearchProductType + '%';
				baseFilter += ' AND buildertek__Product_Type__r.Name LIKE :packageLinesSearchProductType';
			}
			query += baseFilter;
			query += ' ORDER BY buildertek__Trade_Type__r.Name ASC, buildertek__Category__r.Name ASC, buildertek__Product_Type__r.Name ASC, buildertek__Location__c ASC, buildertek__Quantity__c ASC';
			query = query.replace('WHERE OR ', 'WHERE ');
			System.debug('Query::' + query);
			//Retrieve Package Lines - Left Hand Side View.
			List<buildertek__Package_Line__c> packageLinesRecord = Database.query(query);
			if (packageLinesRecord.size() > 0){
				packageLinesWrapper.packageLinesRecord = packageLinesRecord;
			}

			query = 'Select Id,Name,buildertek__Categories__c,buildertek__Source__c, buildertek__Categories__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Location__c, buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Quantity__c FROM buildertek__Project_Takeoff_Lines__c WHERE ';
			baseFilter = '';
			filter = '';

			//TakeOff Lines Search Filter
			if (String.isNotBlank(searchCategory)){
				searchCategory = '%' + searchCategory + '%';
				baseFilter += ' AND buildertek__Categories__r.Name LIKE :searchCategory';
			}
			if (String.isNotBlank(searchTradeType)){
				searchTradeType = '%' + searchTradeType + '%';
				baseFilter += ' AND buildertek__Trade_Type__r.Name LIKE :searchTradeType';
			}
			if (String.isNotBlank(searchProductType)){
				searchProductType = '%' + searchProductType + '%';
				baseFilter += ' AND buildertek__Product_Type__r.Name LIKE :searchProductType';
			}

			System.debug('packageLinesRecord::' + packageLinesRecord);
			//Filter query based on Package Lines.
			for (buildertek__Package_Line__c packageLine : packageLinesRecord){
				filter += packageLine.buildertek__Category__c == null ? ' OR (buildertek__Categories__c = null' : ' OR (buildertek__Categories__c =\'' + packageLine.buildertek__Category__c + '\'';
				filter += packageLine.buildertek__Trade_Type__c == null ? ' AND buildertek__Trade_Type__c = null' : ' AND buildertek__Trade_Type__c =\'' + packageLine.buildertek__Trade_Type__c + '\'';
				filter += packageLine.buildertek__Product_Type__c == null ? ' AND buildertek__Product_Type__c = null' : ' AND buildertek__Product_Type__c =\'' + packageLine.buildertek__Product_Type__c + '\'';
				filter += packageLine.buildertek__Location__c != null ? ' AND buildertek__Location__c = \'' + packageLine.buildertek__Location__c + '\'' : '';
				filter += baseFilter + ' ) ';
			}
			query += filter;
			query = query.replace(' WHERE  OR ', ' WHERE ');
			query += ' ORDER BY buildertek__Trade_Type__r.Name ASC , buildertek__Categories__r.Name ASC, buildertek__Product_Type__r.Name ASC, buildertek__Location__c ASC, buildertek__Quantity__c ASC';
			query += ' LIMIT : pageSize OFFSET : offset';
			System.debug('Query::' + query);
			packageLinesWrapper.takeOffLinesList = Database.query(query);

			query = 'Select COUNT() FROM buildertek__Project_Takeoff_Lines__c WHERE ' + filter;//Total records with Search Query filter.
			query = query.replace(' WHERE  OR ', ' WHERE ');
			packageLinesWrapper.totalRecords = Database.countQuery(query);
			return packageLinesWrapper;
		} catch (Exception e){
			System.debug('Error Message::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static PackageLinesClass getFilteredTakeoffRecords(List<String> takeOffLinesIds, String recordId, Integer pageNumber, Integer pageSize, String packageLinesSearchTradeType, String packageLinesSearchCategory, String packageLinesSearchProductType, String searchTradeType, String searchCategory, String searchProductType, String filteredTakeOffLines){
		try{
			List<buildertek__Package_Line__c> packageLines = (List<buildertek__Package_Line__c>)JSON.deserialize(filteredTakeOffLines, List<buildertek__Package_Line__c>.class);
			PackageLinesClass packageLinesWrapper = new PackageLinesClass();
			//Base Query for TakeOff Lines
			String query = '';
			String filter = '';
			String baseFilter = '';
			Integer offset = (pageNumber - 1) * pageSize;//For TakeOff Lines

			//Retrieve Project TakeOff - Top View.
			packageLinesWrapper.projectTakeOffRec = getProjectTakeOffRec(recordId);

			//Package Lines Search Filter
			query = 'SELECT Id, Name, buildertek__Category__c, buildertek__Category__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name, buildertek__Quantity__c, buildertek__UOM__c, buildertek__Location__c, buildertek__Product_Type__c, buildertek__Product_Type__r.Name, buildertek__Package_Name__c FROM buildertek__Package_Line__c WHERE';
			baseFilter = ' buildertek__Package_Name__c IN :takeOffLinesIds';
			if (String.isNotBlank(packageLinesSearchCategory)){
				packageLinesSearchCategory = '%' + packageLinesSearchCategory + '%';
				baseFilter += ' AND buildertek__Category__r.Name LIKE :packageLinesSearchCategory';
			}
			if (String.isNotBlank(packageLinesSearchTradeType)){
				packageLinesSearchTradeType = '%' + packageLinesSearchTradeType + '%';
				baseFilter += ' AND buildertek__Trade_Type__r.Name LIKE :packageLinesSearchTradeType';
			}
			if (String.isNotBlank(packageLinesSearchProductType)){
				packageLinesSearchProductType = '%' + packageLinesSearchProductType + '%';
				baseFilter += ' AND buildertek__Product_Type__r.Name LIKE :packageLinesSearchProductType';
			}
			for (buildertek__Package_Line__c packageLine : packageLines){
				filter += packageLine.buildertek__Trade_Type__c == null ? ' OR ( ' + baseFilter + ' AND buildertek__Trade_Type__c = null' : ' OR ( ' + baseFilter + ' AND buildertek__Trade_Type__c =\'' + packageLine.buildertek__Trade_Type__c + '\'';
				filter += packageLine.buildertek__Product_Type__c == null ? ' AND buildertek__Product_Type__c = null' : ' AND buildertek__Product_Type__c =\'' + packageLine.buildertek__Product_Type__c + '\'';
				filter += packageLine.buildertek__Category__c == null ? ' AND buildertek__Category__c = null' : ' AND buildertek__Category__c =\'' + packageLine.buildertek__Category__c + '\'';
				filter += packageLine.buildertek__Location__c == null ? ' AND buildertek__Location__c = null)' : ' AND buildertek__Location__c =\'' + packageLine.buildertek__Location__c + '\'' + ')';
			}
			query += packageLines.size() > 0 ? filter : baseFilter;
			query += ' ORDER BY buildertek__Trade_Type__r.Name ASC, buildertek__Category__r.Name ASC, buildertek__Product_Type__r.Name ASC, buildertek__Location__c ASC, buildertek__Quantity__c ASC';
			query = query.replace('WHERE OR ', 'WHERE ');
			System.debug('Query::' + query);
			//Retrieve Package Lines - Left Hand Side View.
			List<buildertek__Package_Line__c> packageLinesRecord = Database.query(query);
			if (packageLinesRecord.size() > 0){
				packageLinesWrapper.packageLinesRecord = packageLinesRecord;
			}

			query = 'Select Id,Name,buildertek__Categories__c,buildertek__Source__c, buildertek__Categories__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Location__c, buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Quantity__c FROM buildertek__Project_Takeoff_Lines__c WHERE ';
			baseFilter = '';
			filter = '';
			Boolean isValueExist = false;
			//TakeOff Lines Search Filter
			if (String.isNotBlank(searchCategory)){
				searchCategory = '%' + searchCategory + '%';
				baseFilter += ' AND buildertek__Categories__r.Name LIKE :searchCategory';
				isValueExist = true;
			}
			if (String.isNotBlank(searchTradeType)){
				searchTradeType = '%' + searchTradeType + '%';
				baseFilter += ' AND buildertek__Trade_Type__r.Name LIKE :searchTradeType';
				isValueExist = true;
			}
			if (String.isNotBlank(searchProductType)){
				searchProductType = '%' + searchProductType + '%';
				baseFilter += ' AND buildertek__Product_Type__r.Name LIKE :searchProductType';
				isValueExist = true;
			}
			System.debug('packageLinesRecord::' + packageLinesRecord);
			//Filter query based on Package Lines.
			for (buildertek__Package_Line__c packageLine : packageLinesRecord){
				filter += packageLine.buildertek__Category__c == null ? ' OR (buildertek__Categories__c = null' : ' OR (buildertek__Categories__c =\'' + packageLine.buildertek__Category__c + '\'';
				filter += packageLine.buildertek__Trade_Type__c == null ? ' AND buildertek__Trade_Type__c = null' : ' AND buildertek__Trade_Type__c =\'' + packageLine.buildertek__Trade_Type__c + '\'';
				filter += packageLine.buildertek__Product_Type__c == null ? ' AND buildertek__Product_Type__c = null' : ' AND buildertek__Product_Type__c =\'' + packageLine.buildertek__Product_Type__c + '\'';
				filter += packageLine.buildertek__Location__c != null ? ' AND buildertek__Location__c = \'' + packageLine.buildertek__Location__c + '\'' : '';
				filter += baseFilter + ' ) ';
			}
			query += filter;
			query = query.replace(' WHERE  OR ', ' WHERE ');
			query += ' ORDER BY buildertek__Trade_Type__r.Name ASC , buildertek__Categories__r.Name ASC, buildertek__Product_Type__r.Name ASC, buildertek__Location__c ASC, buildertek__Quantity__c ASC';
			query += ' LIMIT : pageSize OFFSET : offset';
			System.debug('Query::' + query);
			packageLinesWrapper.takeOffLinesList = Database.query(query);

			query = 'Select COUNT() FROM buildertek__Project_Takeoff_Lines__c WHERE ' + filter;//Total records with Search Query filter.
			query = query.replace(' WHERE  OR ', ' WHERE ');
			packageLinesWrapper.totalRecords = Database.countQuery(query);
			return packageLinesWrapper;

		} catch (Exception e){
			System.debug('Error Message::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
			//throw new AuraHandledException(e.getMessage());
		}
		return null;
	}

	@AuraEnabled
	public static PackageLinesClass addGroupedLinesRecords(List<String> takeOffLinesIds, String recordId, Integer pageNumber, Integer pageSize, String packageLinesSearchTradeType, String packageLinesSearchCategory, String packageLinesSearchProductType, String searchTradeType, String searchCategory, String searchProductType, List<String> listOfIdsToInsert, String groupName){
		try{
			PackageLinesClass packageLineWrapper = new PackageLinesClass();
			Set<Id> insertedTakeOffLines = new Set<Id>();
			List<buildertek__Package_Line__c> packageLinesToInsert = [Select Id, Name, buildertek__Category__c, buildertek__Trade_Type__c, buildertek__UOM__c, buildertek__Location__c, buildertek__Quantity__c, buildertek__Product_Type__c
			                                                          FROM buildertek__Package_Line__c
			                                                          WHERE ID IN :listOfIdsToInsert];

			List<buildertek__Project_Takeoff_Lines__c> takeOffItemsToInsertList = new List<buildertek__Project_Takeoff_Lines__c>();
			for (buildertek__Package_Line__c takeOffItem : packageLinesToInsert){
				buildertek__Project_Takeoff_Lines__c projectTakeOffItemToInsert = new buildertek__Project_Takeoff_Lines__c();
				projectTakeOffItemToInsert.buildertek__Location__c = takeOffItem.buildertek__Location__c;
				projectTakeOffItemToInsert.buildertek__Quantity__c = takeOffItem.buildertek__Quantity__c;
				projectTakeOffItemToInsert.buildertek__Categories__c = takeOffItem.buildertek__Category__c;
				projectTakeOffItemToInsert.buildertek__Product_Type__c = takeOffItem.buildertek__Product_Type__c;
				projectTakeOffItemToInsert.buildertek__Trade_Type__c = takeOffItem.buildertek__Trade_Type__c;
				projectTakeOffItemToInsert.buildertek__Project_Takeoff__c = recordId;
				projectTakeOffItemToInsert.buildertek__UOM__c = takeOffItem.buildertek__UOM__c;
				projectTakeOffItemToInsert.buildertek__Source__c = 'Package';
				takeOffItemsToInsertList.add(projectTakeOffItemToInsert);
			}
			if (takeOffItemsToInsertList.size() > 0){
				insert takeOffItemsToInsertList;
				for (buildertek__Project_Takeoff_Lines__c record : takeOffItemsToInsertList){
					insertedTakeOffLines.add(record.Id);
				}
			}
			packageLineWrapper = getFilteredTakeoffRecords(takeOffLinesIds, recordId, pageNumber, pageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, searchTradeType, searchCategory, searchProductType, '[]');
			packageLineWrapper.insertedTakeOffLines = insertedTakeOffLines;
			return packageLineWrapper;
		} catch (Exception e){
			System.debug('Error Message::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
			//throw new AuraHandledException(e.getMessage());
		}
		return null;
	}

	@AuraEnabled
	public static PackageLinesClass addIndividualTakeOffLinesRecords(List<String> takeOffLinesIds, String recordId, Integer pageNumber, Integer pageSize, String packageLinesSearchTradeType, String packageLinesSearchCategory, String packageLinesSearchProductType, String searchTradeType, String searchCategory, String searchProductType, String packageLineId){
		try{
			PackageLinesClass packageLineWrapper = new PackageLinesClass();
			Set<Id> insertedTakeOffLines = new Set<Id>();
			List<buildertek__Package_Line__c> packageLinesToInsert = [Select Id, Name, buildertek__Category__c, buildertek__Trade_Type__c, buildertek__UOM__c, buildertek__Location__c, buildertek__Quantity__c, buildertek__Product_Type__c
			                                                          FROM buildertek__Package_Line__c
			                                                          WHERE ID = :packageLineId];

			List<buildertek__Project_Takeoff_Lines__c> takeOffItemsToInsertList = new List<buildertek__Project_Takeoff_Lines__c>();
			for (buildertek__Package_Line__c takeOffItem : packageLinesToInsert){
				buildertek__Project_Takeoff_Lines__c projectTakeOffItemToInsert = new buildertek__Project_Takeoff_Lines__c();
				projectTakeOffItemToInsert.buildertek__Location__c = takeOffItem.buildertek__Location__c;
				projectTakeOffItemToInsert.buildertek__Quantity__c = takeOffItem.buildertek__Quantity__c;
				projectTakeOffItemToInsert.buildertek__Categories__c = takeOffItem.buildertek__Category__c;
				projectTakeOffItemToInsert.buildertek__Product_Type__c = takeOffItem.buildertek__Product_Type__c;
				projectTakeOffItemToInsert.buildertek__Trade_Type__c = takeOffItem.buildertek__Trade_Type__c;
				projectTakeOffItemToInsert.buildertek__Project_Takeoff__c = recordId;
				projectTakeOffItemToInsert.buildertek__UOM__c = takeOffItem.buildertek__UOM__c;
				projectTakeOffItemToInsert.buildertek__Source__c = 'Package';
				takeOffItemsToInsertList.add(projectTakeOffItemToInsert);
			}
			if (takeOffItemsToInsertList.size() > 0){
				insert takeOffItemsToInsertList;
				for (buildertek__Project_Takeoff_Lines__c record : takeOffItemsToInsertList){
					insertedTakeOffLines.add(record.Id);
				}
			}
			packageLineWrapper = getFilteredTakeoffRecords(takeOffLinesIds, recordId, pageNumber, pageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, searchTradeType, searchCategory, searchProductType, '[]');
			packageLineWrapper.insertedTakeOffLines = insertedTakeOffLines;
			return packageLineWrapper;
		} catch (Exception e){
			System.debug('Error Message::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
			//throw new AuraHandledException(e.getMessage());
		}
		return null;
	}

	@AuraEnabled
	public static PackageLinesClass deleteTakeOffLinesRecords(List<String> takeOffLinesIds, String recordId, Integer pageNumber, Integer pageSize, String packageLinesSearchTradeType, String packageLinesSearchCategory, String packageLinesSearchProductType, String searchTradeType, String searchCategory, String searchProductType, List<String> takeOffLinesToDeleteList){
		try{
			if (takeOffLinesToDeleteList.size() > 0){
				delete [Select Id
				        FROM buildertek__Project_Takeoff_Lines__c
				        WHERE ID IN :takeOffLinesToDeleteList];
			}
			return getFilteredTakeoffRecords(takeOffLinesIds, recordId, pageNumber, pageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, searchTradeType, searchCategory, searchProductType, '[]');
		} catch (Exception e){
			System.debug('Error Message::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
			//throw new AuraHandledException(e.getMessage());
		}
		return null;
	}

	@AuraEnabled
	public static buildertek__Project_Takeoff__c getProjectTakeOffRec(String recordId){
		try{
			if (String.isNotBlank(recordId)){
				return [Select Id, Name, buildertek__Project__r.Name, buildertek__Community__r.Name, buildertek__Plan_Type__c
				        FROM buildertek__Project_Takeoff__c
				        WHERE Id = :recordId];
			}
		} catch (Exception e){
			System.debug('Error Message::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}

	//Replace All TakeOff Lines
	@AuraEnabled
	public static MessageClass replaceTakeOffLinesRecords(List<String> takeOffLinesIdsToDelete, List<String> takeOffLinesIds, String recordId){
		MessageClass msg = new MessageClass();
		try{
			if (takeOffLinesIdsToDelete.size() > 0){
				delete [Select Id
				        FROM buildertek__Project_Takeoff_Lines__c
				        WHERE Id IN :takeOffLinesIdsToDelete];
			}
			List<buildertek__Package_Line__c> packageLineList = [SELECT Id, Name, buildertek__Category__c, buildertek__Trade_Type__c, buildertek__Quantity__c, buildertek__UOM__c, buildertek__Location__c, buildertek__Product_Type__c, buildertek__Package_Name__c
			                                                     FROM buildertek__Package_Line__c
			                                                     WHERE buildertek__Package_Name__c IN :takeOffLinesIds];


			List<buildertek__Project_Takeoff_Lines__c> takeOffItemsToInsertList = new List<buildertek__Project_Takeoff_Lines__c>();
			if (!packageLineList.isEmpty()){
				for (buildertek__Package_Line__c takeOffItem : packageLineList){
					buildertek__Project_Takeoff_Lines__c projectTakeOffItemToInsert = new buildertek__Project_Takeoff_Lines__c();
					projectTakeOffItemToInsert.buildertek__Location__c = takeOffItem.buildertek__Location__c;
					projectTakeOffItemToInsert.buildertek__Quantity__c = takeOffItem.buildertek__Quantity__c;
					projectTakeOffItemToInsert.buildertek__Categories__c = takeOffItem.buildertek__Category__c;
					projectTakeOffItemToInsert.buildertek__Product_Type__c = takeOffItem.buildertek__Product_Type__c;
					projectTakeOffItemToInsert.buildertek__Trade_Type__c = takeOffItem.buildertek__Trade_Type__c;
					projectTakeOffItemToInsert.buildertek__Project_Takeoff__c = recordId;
					projectTakeOffItemToInsert.buildertek__UOM__c = takeOffItem.buildertek__UOM__c;
					projectTakeOffItemToInsert.buildertek__Source__c = 'Package';
					takeOffItemsToInsertList.add(projectTakeOffItemToInsert);
				}
			}
			if (takeOffItemsToInsertList.size() > 0){
				insert takeOffItemsToInsertList;
				msg.Status = 'Success';
				msg.Message = 'Package Lines Replaced Successfully';
			} else{
				msg.Status = 'Failed';
				msg.Message = 'There were no Package Lines for the selected Package';
			}
			return msg;
		} catch (Exception exp){
			msg.Status = 'Failed';
			msg.Message = exp.getMessage();
			return msg;
		}
	}

	//Replace Individual Lines
	@AuraEnabled
	public static MessageClass replaceTakeOffLinesRecords2(List<String> takeOffLinesIdsToDelete, List<String> takeOffLinesIds, String recordId){
		MessageClass msg = new MessageClass();
		try{
			if (takeOffLinesIdsToDelete.size() > 0){
				delete [Select Id
				        FROM buildertek__Project_Takeoff_Lines__c
				        WHERE Id IN :takeOffLinesIdsToDelete];
			}
			List<buildertek__Package_Line__c> packageLineList = [SELECT Id, Name, buildertek__Category__c, buildertek__Trade_Type__c, buildertek__Quantity__c, buildertek__UOM__c, buildertek__Location__c, buildertek__Product_Type__c, buildertek__Package_Name__c
			                                                     FROM buildertek__Package_Line__c
			                                                     WHERE Id IN :takeOffLinesIds];


			List<buildertek__Project_Takeoff_Lines__c> takeOffItemsToInsertList = new List<buildertek__Project_Takeoff_Lines__c>();
			if (!packageLineList.isEmpty()){
				for (buildertek__Package_Line__c takeOffItem : packageLineList){
					buildertek__Project_Takeoff_Lines__c projectTakeOffItemToInsert = new buildertek__Project_Takeoff_Lines__c();
					projectTakeOffItemToInsert.buildertek__Location__c = takeOffItem.buildertek__Location__c;
					projectTakeOffItemToInsert.buildertek__Quantity__c = takeOffItem.buildertek__Quantity__c;
					projectTakeOffItemToInsert.buildertek__Categories__c = takeOffItem.buildertek__Category__c;
					projectTakeOffItemToInsert.buildertek__Product_Type__c = takeOffItem.buildertek__Product_Type__c;
					projectTakeOffItemToInsert.buildertek__Trade_Type__c = takeOffItem.buildertek__Trade_Type__c;
					projectTakeOffItemToInsert.buildertek__Project_Takeoff__c = recordId;
					projectTakeOffItemToInsert.buildertek__UOM__c = takeOffItem.buildertek__UOM__c;
					projectTakeOffItemToInsert.buildertek__Source__c = 'Package';
					takeOffItemsToInsertList.add(projectTakeOffItemToInsert);
				}
			}
			if (takeOffItemsToInsertList.size() > 0){
				insert takeOffItemsToInsertList;
				msg.Status = 'Success';
				msg.Message = 'Package Lines Replaced Successfully';
			} else{
				msg.Status = 'Failed';
				msg.Message = 'There were no Package Lines for the selected Package';
			}
			return msg;
		} catch (Exception exp){
			msg.Status = 'Failed';
			msg.Message = exp.getMessage();
			return msg;
		}
	}

	@AuraEnabled
	public static PackageLinesClass importPackageLinesRecords(List<String> takeOffLinesIds, String recordId){
		PackageLinesClass response = new PackageLinesClass();
		Set<Id> insertedTakeOffLines = new Set<Id>();
		try{
			List<buildertek__Package_Line__c> packageLineList = [SELECT Id, Name, buildertek__Category__c, buildertek__Trade_Type__c, buildertek__Quantity__c, buildertek__UOM__c, buildertek__Location__c, buildertek__Product_Type__c, buildertek__Package_Name__c
			                                                     FROM buildertek__Package_Line__c
			                                                     WHERE buildertek__Package_Name__c IN :takeOffLinesIds];


			List<buildertek__Project_Takeoff_Lines__c> takeOffItemsToInsertList = new List<buildertek__Project_Takeoff_Lines__c>();
			if (!packageLineList.isEmpty()){
				for (buildertek__Package_Line__c takeOffItem : packageLineList){
					buildertek__Project_Takeoff_Lines__c projectTakeOffItemToInsert = new buildertek__Project_Takeoff_Lines__c();
					projectTakeOffItemToInsert.buildertek__Location__c = takeOffItem.buildertek__Location__c;
					projectTakeOffItemToInsert.buildertek__Quantity__c = takeOffItem.buildertek__Quantity__c;
					projectTakeOffItemToInsert.buildertek__Categories__c = takeOffItem.buildertek__Category__c;
					projectTakeOffItemToInsert.buildertek__Product_Type__c = takeOffItem.buildertek__Product_Type__c;
					projectTakeOffItemToInsert.buildertek__Trade_Type__c = takeOffItem.buildertek__Trade_Type__c;
					projectTakeOffItemToInsert.buildertek__Project_Takeoff__c = recordId;
					projectTakeOffItemToInsert.buildertek__UOM__c = takeOffItem.buildertek__UOM__c;
					projectTakeOffItemToInsert.buildertek__Source__c = 'Package';
					takeOffItemsToInsertList.add(projectTakeOffItemToInsert);
				}
			}
			if (takeOffItemsToInsertList.size() > 0){
				insert takeOffItemsToInsertList;
				for (buildertek__Project_Takeoff_Lines__c record : takeOffItemsToInsertList){
					insertedTakeOffLines.add(record.Id);
				}
				response = getPackageTakeoffRecords(takeOffLinesIds, recordId, 1, 10, '', '', '', '', '', '');
				response.insertedTakeOffLines = insertedTakeOffLines;
				response.Status = 'Success';
				response.Message = 'Package Lines Added Successfully';
				return response;
			} else{
				response.Status = 'Failed';
				response.Message = 'There were no Package Lines for the selected Package';
			}
			return response;
		} catch (Exception exp){
			response.Status = 'Failed';
			response.Message = exp.getMessage();
			return response;
		}
	}

	//This is in use in main Quick Action Button
	@AuraEnabled
	public static PackageLinesClass importPackageLines(List<String> takeOffLinesIds, String recordId){
		PackageLinesClass response = new PackageLinesClass();
		try{
			List<buildertek__Package_Line__c> packageLineList = [SELECT Id, Name, buildertek__Category__c, buildertek__Trade_Type__c, buildertek__Quantity__c, buildertek__UOM__c, buildertek__Location__c, buildertek__Product_Type__c, buildertek__Package_Name__c
			                                                     FROM buildertek__Package_Line__c
			                                                     WHERE buildertek__Package_Name__c IN :takeOffLinesIds];


			List<buildertek__Project_Takeoff_Lines__c> takeOffItemsToInsertList = new List<buildertek__Project_Takeoff_Lines__c>();
			if (!packageLineList.isEmpty()){
				for (buildertek__Package_Line__c takeOffItem : packageLineList){
					buildertek__Project_Takeoff_Lines__c projectTakeOffItemToInsert = new buildertek__Project_Takeoff_Lines__c();
					projectTakeOffItemToInsert.buildertek__Location__c = takeOffItem.buildertek__Location__c;
					projectTakeOffItemToInsert.buildertek__Quantity__c = takeOffItem.buildertek__Quantity__c;
					projectTakeOffItemToInsert.buildertek__Categories__c = takeOffItem.buildertek__Category__c;
					projectTakeOffItemToInsert.buildertek__Product_Type__c = takeOffItem.buildertek__Product_Type__c;
					projectTakeOffItemToInsert.buildertek__Project_Takeoff__c = recordId;
					projectTakeOffItemToInsert.buildertek__Trade_Type__c = takeOffItem.buildertek__Trade_Type__c;
					projectTakeOffItemToInsert.buildertek__UOM__c = takeOffItem.buildertek__UOM__c;
					takeOffItemsToInsertList.add(projectTakeOffItemToInsert);
				}
			}
			System.debug('Items To Insert::' + takeOffItemsToInsertList);
			if (takeOffItemsToInsertList.size() > 0){
				insert takeOffItemsToInsertList;
				response = getPackageTakeoffRecords(takeOffLinesIds, recordId, 1, 10, '', '', '', '', '', '');
				response.Status = 'Success';
				response.Message = 'Package Lines Added Successfully';
			} else{
				response.Status = 'Failed';
				response.Message = 'There were no Package Lines for the selected Package';
			}
			return response;
		} catch (Exception exp){
			response.Status = 'Failed';
			response.Message = exp.getMessage();
			return response;
		}
	}

	public class ProjectClass{
		@AuraEnabled
		public buildertek__Package__c packageRecord{ get; set; }

		@AuraEnabled
		public Boolean packageTakeOffCheck{ get; set; }
	}

	public class PackageLinesClass{
		@AuraEnabled
		public Integer totalRecords;
		@AuraEnabled
		public buildertek__Project_Takeoff__c projectTakeOffRec;

		@AuraEnabled
		public List<buildertek__Package_Line__c> packageLinesRecord{ get; set; }

		@AuraEnabled
		public List<buildertek__Project_Takeoff_Lines__c> takeOffLinesList{ get; set; }

		@AuraEnabled
		public Set<Id> insertedTakeOffLines{ get; Set; }

		@AuraEnabled
		public String Status{ get; set; }

		@AuraEnabled
		public string Message{ get; set; }
	}

	public class MessageClass{
		@AuraEnabled
		public String Status{ get; set; }

		@AuraEnabled
		public string Message{ get; set; }
	}
}