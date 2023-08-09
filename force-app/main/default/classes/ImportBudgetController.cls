public with sharing class ImportBudgetController{
	// public Blob fileContent {get; set;}
	// public String strFileName {get; set;}
	// public ImportBudgetController(ApexPages.StandardSetController controller) {}
	public virtual class ResponseBase{
		@AuraEnabled
		public Boolean isSuccess;
		@AuraEnabled
		public String strMessage;
		@AuraEnabled
		public String strRecordId;
	}

	@AuraEnabled
	public static ResponseBase importBudgets(Id budgetId, String fileData){
		ResponseBase response = new ResponseBase();
		response.isSuccess = true;
		WrapperClass wrapper = new WrapperClass();
		Set<String> groupNames = new Set<String>();
		try{
			if (fileData != null){
				List<List<String>> listCSVData;
				String strFileData;
				Blob fileContent = EncodingUtil.base64Decode(fileData);
				try{
					//strFileData = EncodingUtil.base64Encode(EncodingUtil.base64Decode(fileData));
					strFileData = fileContent.toString();
				} catch (Exception ex){
					try{
						strFileData = EncodingUtil.base64Encode(fileContent);
						System.debug('Message:0:' + ex.getMessage());
						System.debug('Line:0:' + ex.getLineNumber());
					} catch (Exception iex){
						response.isSuccess = false;
						response.strMessage = iex.getMessage();
						System.debug('Message:1:' + iex.getMessage());
						System.debug('Line:1:' + iex.getLineNumber());
					}
				}

				if (!String.isBlank(strFileData) && response.isSuccess){
					List<buildertek__Budget_Item__c> listBudgets = new List<buildertek__Budget_Item__c>();
					wrapper = getListOfFileContentsAsStrings(strFileData);
					listCSVData = wrapper.listOfFileContentsAsStrings;
					groupNames = wrapper.groupNames;
					Map<String, buildertek__Budget_Line_Group__c> existingGroupMap = new Map<String, buildertek__Budget_Line_Group__c>();
					Map<String, buildertek__Budget_Line_Group__c> newGroupMap = new Map<String, buildertek__Budget_Line_Group__c>();
					for (buildertek__Budget_Line_Group__c budgetLines : [Select Id, Name
					                                                     FROM buildertek__Budget_Line_Group__c]){
						existingGroupMap.put(budgetLines.Name, budgetLines);
					}
					for (String groupName : groupNames){
						if (!existingGroupMap.containsKey(groupName)){
							buildertek__Budget_Line_Group__c newGroup = new buildertek__Budget_Line_Group__c();
							newGroup.Name = groupName;
							newGroupMap.put(groupName, newGroup);
						}
					}
					if (newGroupMap.size() > 0){
						insert newGroupMap.values();
					}

					for (Integer intIndex = 1; intIndex < listCSVData.size(); intIndex++){
						Budget_Item__c budget = new Budget_Item__c(Budget__c = budgetId);

						for (Integer intInnerIndex = 0; intInnerIndex < listCSVData.get(intIndex).size(); intInnerIndex++){
							switch on listCSVData.get(0).get(intInnerIndex){
								when 'Grouping'{
									if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
										String tempGroupNames  = listCSVData.get(intIndex).get(intInnerIndex).replace('\n', '');
										if (existingGroupMap.containsKey(tempGroupNames)){
											budget.buildertek__Group__c = existingGroupMap.get(tempGroupNames).Id;
										} else if (newGroupMap.containsKey(listCSVData.get(intIndex).get(intInnerIndex))){
											budget.buildertek__Group__c = newGroupMap.get(tempGroupNames).Id;
										}
									}
								}

								when 'Product Name'{
									if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
										budget.buildertek__Description__c = listCSVData.get(intIndex).get(intInnerIndex);
										budget.Name = listCSVData.get(intIndex).get(intInnerIndex);
									}
								}

								when 'Quantity'{
									if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
										budget.Quantity__c = Decimal.valueOf(listCSVData.get(intIndex).get(intInnerIndex));
									}
								}

								when 'Unit Price'{
									if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){										
										budget.Unit_Price__c = Decimal.valueOf(listCSVData.get(intIndex).get(intInnerIndex).replaceAll('[^.\\d]',''));
									}
								}

								when 'UOM'{
									// budget.Product__c = listCSVData.get(intIndex).get(intInnerIndex);
								}

								when 'Budget Mods'{
									// budget.Product__c = listCSVData.get(intIndex).get(intInnerIndex);
								}

								when 'Projected Costs'{
									// budget.Product__c = listCSVData.get(intIndex).get(intInnerIndex);
								}
								when 'Tax'{
									if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
										budget.buildertek__Tax__c = Decimal.valueOf(listCSVData.get(intIndex).get(intInnerIndex));
									}
								}
							}
						}
						listBudgets.add(budget);
					}
					if (!listBudgets.isEmpty()){
						insert listBudgets;
						response.strMessage = 'Budget line items inserted successfully.';
					} else{
						response.isSuccess = false;
						response.strMessage = 'No budget line items present.';
					}
				} else{
					response.isSuccess = false;
					response.strMessage = 'Please select valid CSV file.';
				}
			}
		} catch (Exception ex){
			response.isSuccess = false;
			response.strMessage = ex.getMessage();
			System.debug('Message:2:' + ex.getMessage());
			System.debug('Line:2:' + ex.getLineNumber());
		}
		return response;
	}

	/*
	 @ Purpose     : Parse each row and column value into the element of List.
	 @ Parameters  : String [ Contents of CSV file ].
	 @ Return Type : List<List<String>> [ List of rows and Each row will have the list of columns ].
	 */
	public static WrapperClass getListOfFileContentsAsStrings(String strContents){
		WrapperClass wrapper = new WrapperClass();
		List<List<String>> listOfFileContentsAsStrings;
		Set<String> groupNames = new Set<String>();
		if (String.isNotBlank(strContents)){
			List<String> listLines;

			if (strContents.contains('\r')){
				// Split up the file contents into List of rows [ Using new line ].
				listLines = strContents.split('\r');
			} else if (strContents.contains('\n')){
				// Split up the file contents into List of rows [ Using new line ].
				listLines = strContents.split('\n');
			}

			if (listLines != Null && !listLines.isEmpty()){
				// Appending cell values separated by New Lines.
				listLines = appendCellValuesSeparatedByNewLines(listLines);
				if (listLines != Null && !listLines.isEmpty()){

					// Split up the each element of the list into List of columns [ Using comma ].
					List<String> listRowContents;
					listOfFileContentsAsStrings = new List<List<String>>();
					for (String line : listLines){

						if (line.contains(',')){
							listRowContents = line.split(',');
							if (listRowContents != Null && !listRowContents.isEmpty()){

								// Appending cell values separated by Commas.
								listRowContents = appendCellValuesSeparatedByCommas(listRowContents);
								if (listRowContents != Null && !listRowContents.isEmpty()){
									listOfFileContentsAsStrings.add(listRowContents);
									groupNames.add(listRowContents[0].replace('\n',''));
								}
							}
						}
					}
				}
			}
		}

		wrapper.listOfFileContentsAsStrings = listOfFileContentsAsStrings;
		wrapper.groupNames = groupNames;
		return wrapper;
	}

	/*
	 @ Purpose     : Appends the CSV cells which are separated by New Line.
	 @ Parameters  : List<String> [ List holds the strings separated by New Line ].
	 @ Return Type : List<String> [ List appends the strings belong to same CSV cell ].
	 */
	public Static List<String> appendCellValuesSeparatedByNewLines(List<String> listValues){

		List<String> listToAppendCellValues;
		if (listValues != Null && !listValues.isEmpty()){

			Boolean isNewLineFound = False;
			String strValueToBeMerged = '';
			listToAppendCellValues = new List<String>();
			Integer intCountDoubleQuotes;

			for (String strValue : listValues){

				if (!isNewLineFound){
					intCountDoubleQuotes = strValue.countMatches('\"');
					if (intCountDoubleQuotes == 1){
						isNewLineFound = True;
					}
				}

				if (isNewLineFound){
					strValueToBeMerged += strValue + '\n';
					if (strValue.contains('\",')){

						intCountDoubleQuotes = strValue.countMatches('\"');
						if (Math.mod(intCountDoubleQuotes, 2) != 0){

							isNewLineFound = False;
							listToAppendCellValues.add(strValueToBeMerged);
							strValueToBeMerged = '';
						}
					}
				} else{
					listToAppendCellValues.add(strValue);
				}
			}
		}
		return listToAppendCellValues;
	}

	/*
	 @ Purpose     : Appends the CSV cells which are separated by Commas.
	 @ Parameters  : List<String> [ List holds the strings separated by Commas ].
	 @ Return Type : List<String> [ List appends the strings belong to same CSV cell ].
	 */
	public static List<String> appendCellValuesSeparatedByCommas(List<String> listValues){

		List<String> listToAppendCellValues;
		if (listValues != Null && !listValues.isEmpty()){

			Boolean isCommaFoundInTheValue;
			listToAppendCellValues = new List<String>();
			String strValueToBeMerged = '';
			Integer intCountDoubleQuotes = 0;

			for (String strValue : listValues){

				if (isCommaFoundInTheValue == Null){
					if (strValue.startsWith('\"')){
						isCommaFoundInTheValue = True;
						if (strValue.endsWith('\"')){
							if (strValue.contains('\n') || strValue.contains('\r')){
								isCommaFoundInTheValue = False;
							} else{
								intCountDoubleQuotes = strValue.countMatches('\"');
								if (Math.mod(intCountDoubleQuotes, 2) == 0){
									isCommaFoundInTheValue = False;
								}
							}
						}
					}
				} else if (strValue.endsWith('\"')){
					intCountDoubleQuotes = strValue.countMatches('\"');
					if (Math.mod(intCountDoubleQuotes, 2) != 0){
						isCommaFoundInTheValue = False;
					}
				}

				if (isCommaFoundInTheValue != Null){
					if (isCommaFoundInTheValue){
						strValueToBeMerged += strValue + ',';
					} else{
						strValueToBeMerged += strValue;
						if (strValueToBeMerged.contains('\"')){
							strValueToBeMerged = strValueToBeMerged.replaceAll('\\\"+', '"');
						}
						listToAppendCellValues.add(strValueToBeMerged);
						strValueToBeMerged = '';
						isCommaFoundInTheValue = Null;
					}
				} else{
					listToAppendCellValues.add(strValue);
				}
			}
		}
		return listToAppendCellValues;
	}

	public class WrapperClass{
		public List<List<String>> listOfFileContentsAsStrings;
		public Set<String> groupNames;

	}
}