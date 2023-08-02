/*
 Copyright (c) 2017-2018, BuilderTek.
 All rights reserved.

 Developed By: Sagar
 Date:  17-Jul-2018
 */
public with sharing class BT_QuestionnaireBuilder{
	@AuraEnabled
	public static String getSelection(String recordId){
		List<buildertek__Selection__c> selectionName = [Select Id, Name, buildertek__Project__r.Name
		                                                from buildertek__Selection__c
		                                                WHERE Id = :recordId
		                                                LIMIT 1];
		if (selectionName.size() > 0){
			return selectionName[0].buildertek__Project__r.Name;
		}
		return null;
	}

	@AuraEnabled
	public static Boolean getImageVisibility(String recordId){
		List<buildertek__Selection__c> selectionName = [Select Id, buildertek__Hide_Images__c
		                                                from buildertek__Selection__c
		                                                WHERE Id = :recordId
		                                                LIMIT 1];
		if (selectionName.size() > 0){
			return selectionName[0].buildertek__Hide_Images__c;
		}
		return false;
	}

	@AuraEnabled
	public static String retriveContentVersionId(String documentId){
		if (String.isNotBlank(documentId)){
			System.debug('Content Document Id::' + documentId);
			ContentDocument contentDoc = [SELECT Id, Title, ParentId, LatestPublishedVersionId
			                              FROM ContentDocument
			                              WHERE Id = :documentId
			                              LIMIT 1];
			return String.isNotBlank(contentDoc.LatestPublishedVersionId) ? contentDoc.LatestPublishedVersionId : 'Error';
		}
		return null;
	}

	@AuraEnabled
	public static Boolean checkIfCustomerCommunity(){
		String user = Userinfo.getUserType();
		if (String.isNotBlank(user)  && user == 'PowerCustomerSuccess'){
			return true;
		} else{
			return false;
		}
		return false;
	}

	@AuraEnabled
	public static citationDetails retrieveCitations(String adId){
		String strRSQuery;

		strRSQuery = 'SELECT Id, Name, Title__c, Parent__c, Selection__c, buildertek__Visible_to_Customer__c';
		strRSQuery += ' FROM Section__c WHERE Selection__c = :adId ORDER BY Name ASC';

		citationDetails citationDetail = new citationDetails();

		citationDetail.citationByParentId = new Map<Id, List<Section__c>>();
		citationDetail.citations = new List<Section__c>();
		citationDetail.sectionHeaderFields = new List<String>();


		for (Section__c citation : Database.query(String.escapeSingleQuotes(strRSQuery))){
			if (citation.Parent__c != null){
				if (citationDetail.citationByParentId.containsKey(citation.Parent__c)){
					citationDetail.citationByParentId.get(citation.Parent__c).add(citation);
				} else{
					citationDetail.citationByParentId.put(citation.Parent__c, new List<Section__c>{ citation });
				}
			} else{
				citationDetail.citations.add(citation);
			}
		}

		for (Schema.FieldSetMember fm : BT_Utils.getFieldSetMembers('Section_Header_FieldSet', BT_CONSTANTS.OBJECT_TYPE_SECTION)){
			citationDetail.sectionHeaderFields.add(fm.getFieldPath());
		}

		return citationDetail;
	}

	@AuraEnabled
	public Static String deleteImage(String questionId){
		if (String.isNotBlank(questionId)){
			List<buildertek__Question__c> questions = [SELECT Id, buildertek__Image_Id__c
			                                           FROM buildertek__Question__c
			                                           where Id = :questionId
			                                           Limit 1];
			for (buildertek__Question__c question : questions){
				question.buildertek__Image_Id__c = '';
			}
			update questions;
		}
		return 'Success';
	}

	@AuraEnabled
	public static void updateQuestion(String documentId, String questionId){

		List<buildertek__Question__c> questionRec = [SELECT Id, buildertek__Image_Id__c
		                                             FROM buildertek__Question__c
		                                             where id = :questionId
		                                             Limit 1];
		if (questionRec.size() == 0){
			return;
		}
		List<ContentVersion> conVer = [SELECT Id, ContentDocumentId
		                               FROM ContentVersion
		                               WHERE Id = :questionRec[0].buildertek__Image_Id__c
		                               LIMIT 1];
		if (conVer.size() != 0){
			Delete [SELECT Id
			        FROM ContentDocument
			        WHERE Id = :conVer[0].ContentDocumentId];
		}

		ContentVersion newContentVersion = [SELECT Id, ContentDocumentId
		                                    FROM ContentVersion
		                                    where contentDocumentId = :documentId
		                                    LIMIT 1];
		questionRec[0].buildertek__Image_Id__c = newContentVersion.Id;
		questionRec[0].buildertek__Document_Id__c = documentId;
		update questionRec;
	}

	@AuraEnabled
	public static void saveQuestion(String questions){
		try{
			List<buildertek__Question__c> questionRecs = (List<buildertek__Question__c>)JSON.deserialize(questions, List<buildertek__Question__c>.class);
			if (questionRecs.size() > 0){
				update questionRecs;
			}
		} catch (Exception e){
			System.debug(e.getMessage());
		}
	}

	@AuraEnabled
	public static void saveAttributeTypeValue(String questions, String choices){
		System.debug('questions :: ' + questions);
		try{
			Map<Id, Decimal> questionGroupMap = new Map<Id, Decimal>();

			List<buildertek__Question__c> questionRecs = (List<buildertek__Question__c>)JSON.deserialize(questions, List<buildertek__Question__c>.class);
			for (buildertek__Question__c questionRec : questionRecs){
				if (questionRec.buildertek__Is_Selected_Item__c){
					if (!questionGroupMap.containsKey(questionRec.buildertek__Question_Group__c)){
						questionGroupMap.put(questionRec.buildertek__Question_Group__c, 0.0);
					}
					if (questionRec.buildertek__Cost__c != null){
						questionGroupMap.put(questionRec.buildertek__Question_Group__c, questionGroupMap.get(questionRec.buildertek__Question_Group__c) + questionRec.buildertek__Cost__c);
					}
				}
			}
			update questionRecs;

			List<buildertek__Question_Group__c> qGroupLst = new List<buildertek__Question_Group__c>();
			for (Id questionGroupId : questionGroupMap.keySet()){
				buildertek__Question_Group__c qGroup = new buildertek__Question_Group__c();
				qGroup.Id = questionGroupId;
				qGroup.buildertek__Allowance_Used__c = questionGroupMap.get(questionGroupId);
				qGroupLst.add(qGroup);
			}

			update qGroupLst;

			List<buildertek__Answer_Choice__c> answerChoice = (List<buildertek__Answer_Choice__c>)JSON.deserialize(choices, List<buildertek__Answer_Choice__c>.class);
			System.debug('answerChoice :: ' + answerChoice);
			update answerChoice;
		} catch (Exception e){
			System.debug(e.getMessage());
		}
	}

	@AuraEnabled
	public static void addNewAnswerChoices(String choices){
		List<buildertek__Answer_Choice__c> answerChoice = (List<buildertek__Answer_Choice__c>)JSON.deserialize(choices, List<buildertek__Answer_Choice__c>.class);
		upsert answerChoice;
	}

	@AuraEnabled
	public static void saveAttribute(String questions, String choices){
		try{
			List<buildertek__Question__c> qList = (List<buildertek__Question__c>)JSON.deserialize(questions, List<buildertek__Question__c>.class);
			update qList;

			Map<Id, Decimal> questionGroupMap = new Map<Id, Decimal>();
			Map<Id, Boolean> questionGroupMap2 = new Map<Id, Boolean>();
			//Save And Lock Attribute revert changes.
			//Integer countSelected = 0;
			//Integer countTrue = 0;
			//Integer totalQuestions = qList.size();

			for (buildertek__Question__c questionRec : qList){
				if (questionRec.buildertek__Is_Selected_Item__c != null && questionRec.buildertek__Question_Group__c != null && questionRec.buildertek__Is_Selected_Item__c){
					//countSelected++;
					if (!questionGroupMap.containsKey(questionRec.buildertek__Question_Group__c)){
						questionGroupMap.put(questionRec.buildertek__Question_Group__c, 0.0);
					}
					if (questionRec.buildertek__Cost__c != null){
						questionGroupMap.put(questionRec.buildertek__Question_Group__c, questionGroupMap.get(questionRec.buildertek__Question_Group__c) + questionRec.buildertek__Cost__c);
					}
				}
			}

			List<buildertek__Question_Group__c> qGroupLst = new List<buildertek__Question_Group__c>();
			for (Id questionGroupId : questionGroupMap.keySet()){
				buildertek__Question_Group__c qGroup = new buildertek__Question_Group__c();
				qGroup.Id = questionGroupId;
				qGroup.buildertek__Allowance_Used__c = questionGroupMap.get(questionGroupId);
				//Logic for lock option when user save attributes.
				/*if (countSelected > 0){
				 qGroup.buildertek__Locked__c = true;
				 } else if (countSelected == 0){
				 qGroup.buildertek__Locked__c = false;
				 }*/
				qGroupLst.add(qGroup);
			}

			update qGroupLst;

			List<buildertek__Answer_Choice__c> answerChoice = (List<buildertek__Answer_Choice__c>)JSON.deserialize(choices, List<buildertek__Answer_Choice__c>.class);
			update answerChoice;
		} catch (Exception e){
			System.debug('Error :: ' + e.getMessage());
		}
	}

	@AuraEnabled
	public static controlDetails retrieveControls(String citationId){
		String strRSQuery;

		strRSQuery = 'SELECT Id, Name, Title__c, Parent__c, Section__c,buildertek__Is_Saved_Items__c,buildertek__Locked__c,';
		strRSQuery += '(SELECT Id, Name, buildertek__Selection_Type__c,buildertek__Choice_Value__c,buildertek__Choice_Text__c FROM buildertek__Selection_Attributes__r WHERE buildertek__Question__c=null)';
		strRSQuery += ' FROM Question_Group__c WHERE Section__c =: citationId ORDER BY Sort_Id__c, CreatedDate, Name ASC';

		controlDetails controlDetail = new controlDetails();

		controlDetail.controlByParentId = new Map<Id, List<Question_Group__c>>();
		controlDetail.controls = new List<Question_Group__c>();
		controlDetail.controlHeaderFields = new List<String>();

		Set<Id> r = new Set<Id>();
		for (Question_Group__c control : Database.query(String.escapeSingleQuotes(strRSQuery))){
			if (control.Parent__c != null){
				if (controlDetail.controlByParentId.containsKey(control.Parent__c)){
					controlDetail.controlByParentId.get(control.Parent__c).add(control);
				} else{
					controlDetail.controlByParentId.put(control.Parent__c, new List<Question_Group__c>{ control });
				}
			} else{
				controlDetail.controls.add(control);
			}
		}

		for (Schema.FieldSetMember fm : BT_Utils.getFieldSetMembers('QuestionGroup_Header_FieldSet', BT_CONSTANTS.OBJECT_TYPE_QUESTION_GROUP)){
			controlDetail.controlHeaderFields.add(fm.getFieldPath());
		}

		return controlDetail;
	}

	@AuraEnabled
	public static QuestionData getQuestionInfo(String priceBookId, String productId){
		QuestionData questionData = new QuestionData();
		if (productId != null){
			try{
				String docQuery = 'SELECT Id, LinkedEntityId,ContentDocument.FileType,ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =:productId ';
				List<ContentDocumentLink> conDocLinkRecs = (List<ContentDocumentLink>)Database.query(docQuery);
				List<String> fileType = new List<String>();
				fileType.add('JPG');
				fileType.add('PNG');
				fileType.add('JPEG');
				for (ContentDocumentLink conDocLinkRec : conDocLinkRecs){
					if (conDocLinkRec.ContentDocument.FileType != null && fileType.contains(conDocLinkRec.ContentDocument.FileType)){
						questionData.documentId = conDocLinkRec.ContentDocumentId;
						break;
					}
				}
				if (questionData.documentId != null){
					String docVersionQuery = 'SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = \'' + questionData.documentId + '\'';
					try{
						List<ContentVersion> conVerRecs = (List<ContentVersion>)Database.query(docVersionQuery);
						for (ContentVersion conVerRec : conVerRecs){
							questionData.imageId = conVerRec.Id;
							break;
						}
					} catch (Exception e){
						System.debug('error :' + e.getMessage());
					}
				}
			} catch (Exception e){
				System.debug('error :: ' + e.getMessage());
			}
		}
		String query = 'SELECT Id,Product2.Description,Product2.buildertek__Instructions__c,Product2.buildertek__Vendor__c,Product2.buildertek__Manufacturer__c,Product2.ProductCode,Product2.buildertek__Finish__c,Product2.buildertek__Color__c, Product2Id,Product2.Name, UnitPrice, Pricebook2Id ,Pricebook2.Name FROM PricebookEntry WHERE Product2Id=\'' + productId + '\' AND Pricebook2Id = \'' + priceBookId + '\'';
		try{
			List<PriceBookEntry> priceBookEntryRecs = (List<PriceBookEntry>)Database.query(query);
			if (priceBookEntryRecs.size() > 0){
				if (priceBookEntryRecs[0].Product2Id != null && priceBookEntryRecs[0].Product2.buildertek__Instructions__c != null){
					priceBookEntryRecs[0].Product2.buildertek__Instructions__c = priceBookEntryRecs[0].Product2.buildertek__Instructions__c.replaceAll('<[^>]+>', ' ');
				}
				questionData.PriceBookEntry = priceBookEntryRecs[0];
			}
		} catch (Exception e){
			System.debug('error :: ' + e.getMessage());
		}
		system.debug('query::' + query);
		system.debug('questionData::' + questionData);
		return questionData;
	}

	@AuraEnabled
	//get Pricebook Values
	public static Map<String, String> getpricebooks(){
		Map<String, String> options = new Map<String, String>();
		list<pricebook2> PriceList;
		/* if(Schema.sObjectType.pricebook2.fields.Id.isAccessible()&&
		 Schema.sObjectType.pricebook2.fields.Name.isAccessible()){*/
		PriceList = [select Id, Name
		             from pricebook2
		             Where isActive = true];
		/* }*/
		for (pricebook2 p : PriceList){
			//Put Picklist Value & Label in Map
			options.put(p.name, p.Id);
		}
		return options;
	}

	@AuraEnabled
	//get ProdcutFamily  Picklist Values
	public static Map<String, String> getselectOptionsforproductfamily(){
		Map<String, String> options = new Map<String, String>();
		//get product2 Product2 Field Describe
		Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();
		//get Product2 Product2 Picklist Values
		List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry p : pList){
			//Put Picklist Value & Label in Map
			options.put(p.getValue(), p.getLabel());
		}
		system.debug('options----' + options);
		return options;
	}

	@AuraEnabled
	public static Boolean retriveChangeNodeConfig(){
		buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id, buildertek__Change_Order_Configuration__c
		                                                                                      from buildertek__Admin_Interface_Node_Configuration__c
		                                                                                      WHERE Name = :'Change Order Configuration'];
		return adminInterfaceNodeConfigurations.buildertek__Change_Order_Configuration__c;
	}

	@AuraEnabled
	public static Boolean retriveAllowanceOverage(){
		List<buildertek__Admin_Interface_Node_Configuration__c> adminConfig = [Select Id, buildertek__Change_Order_Configuration__c
		                                                                       from buildertek__Admin_Interface_Node_Configuration__c
		                                                                       WHERE Name = :'Turn off Cost Option Allowance Check'
		                                                                       LIMIT 1];
		if (adminConfig.size() > 0){
			return adminConfig[0].buildertek__Change_Order_Configuration__c;
		}
		return false;
	}

	@AuraEnabled
	public static List<questionDetails> retrieveQuestions(String controlId){
		System.debug('=== === retrieveQuestions === ===');

		//SOQL query on checks based on check ids which are in set of check id.
		String checkQuery = 'SELECT buildertek__Product__r.Name, buildertek__Section__r.buildertek__Visible_to_Customer__c,buildertek__Section__r.buildertek__Create_Change_Order_on_Overage__c,buildertek__Question_Group__r.buildertek__of_Options_Required__c,buildertek__Question_Group__r.buildertek__Allowance_Available__c,buildertek__Question_Group__r.buildertek__Allowance_Remaining__c,buildertek__Question_Group__r.buildertek__Is_Saved_Items__c,' + BT_Utils.getQueryStringForObjectWithAllFields('buildertek__Question__c');
		System.debug('Retrive checkQuery---->' + checkQuery);
		checkQuery += ' ,(SELECT Id,Name,buildertek__Question__c,buildertek__Selection_Type__c,buildertek__Choice_Value__c,buildertek__Text_Value__c,buildertek__Choice_Text__c,buildertek__Single_Select_Drop_Down__c, buildertek__Single_Select_Radio__c, buildertek__Single_Select_Horizontal_Radio__c, buildertek__Multi_Select_CheckBox__c, buildertek__Multi_Select_Horizontal_CheckBox__c, buildertek__Multi_Select_Drop_Down__c, buildertek__Simple_Text__c, buildertek__Long_Text__c, buildertek__Date__c, buildertek__Drop_Down_Value__c,buildertek__Photo_Ids__c,buildertek__Additional_Cost__c,buildertek__ParentId__c,buildertek__Parent_Level__c,buildertek__Level__c,buildertek__Image_Id__c,buildertek__Document_Id__c FROM buildertek__Answer_Choices__r ORDER BY  CreatedDate ASC) FROM ' + BT_CONSTANTS.OBJECT_TYPE_QUESTION + ' WHERE Question_Group__c =:controlId ORDER BY Sort_Id__c, CreatedDate, Name ASC';
		System.debug('checkQuery---->' + checkQuery);
		List<buildertek__Question__c> checks;
		/*if(Schema.sObjectType.buildertek__Question__c.fields.Id.isAccessible()&&
		 Schema.sObjectType.buildertek__Question__c.fields.Name.isAccessible()&&
		 Schema.sObjectType.buildertek__Question__c.fields.Question_Group__c.isAccessible()&&
		 Schema.sObjectType.buildertek__Question__c.fields.Sort_Id__c.isAccessible()&&
		 Schema.sObjectType.buildertek__Answer_Choice__c.fields.Id.isAccessible() &&
		 Schema.sObjectType.buildertek__Answer_Choice__c.fields.Name.isAccessible()&&
		 Schema.sObjectType.buildertek__Answer_Choice__c.fields.buildertek__Question__c.isAccessible() &&
		 Schema.sObjectType.buildertek__Answer_Choice__c.fields.buildertek__Choice_Text__c.isAccessible() &&
		 Schema.sObjectType.buildertek__Answer_Choice__c.fields.buildertek__Photo_Ids__c.isAccessible()){*/
		checks = Database.query(checkQuery);
		System.debug('checkQuery :: ' + checks);
		/*}*/
		Set<Id> choiceTemplateId = new Set<Id>();
		for (Question__c check : checks){
			choiceTemplateId.Add(check.Choice_Template__c);
		}

		List<fieldset> otherfields = new List<fieldset>();
		for (Schema.FieldSetMember fm : BT_Utils.getFieldSetMembers('Section_Option_Addition_Fields', BT_CONSTANTS.OBJECT_TYPE_QUESTION)){
			fieldset fieldset = new fieldset();
			fieldset.fieldlabel = fm.getLabel();
			fieldset.fieldPath = fm.getFieldPath();
			fieldset.dataType = String.valueOf(fm.getType()).toUpperCase();
			otherfields.add(fieldset);
		}


		Map<Id, String> answerChoicesByChoiceTemplateId = fillMapOfChoiceTemplateAnswerChoices(choiceTemplateId);
		List<questionDetails> questions = new List<questionDetails>();
		Set<Id> productSet = new Set<Id>();
		Set<Id> questionGroup = new Set<Id>();
		Set<String> sectionChnageOrder = new Set<String>();
		for (Question__c check : checks){
			if (check.buildertek__Section__c != null){
				sectionChnageOrder.add(check.buildertek__Section__c);
			}
			if (check.buildertek__Product__c != null){
				productSet.add(check.buildertek__Product__c);
			}
			if (check.buildertek__Question_Group__c != null || String.isNotBlank(check.buildertek__Question_Group__c)){
				questionGroup.add(check.buildertek__Question_Group__c);
			}
		}
		List<ContentDocumentLink> contentDocumentLinkRecs = new List<ContentDocumentLink>();
		if (productSet.size() > 0){
			contentDocumentLinkRecs = [SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.fileType, ContentDocument.title
			                           FROM ContentDocumentLink
			                           Where LinkedEntityId IN:productSet];
		}
		System.debug('******' + contentDocumentLinkRecs);
		Map<Id, List<ContentDocumentLink>> productToDocumentMap = new Map<Id, List<ContentDocumentLink>>();
		List<String> fileType = new List<String>();
		fileType.add('JPG');
		fileType.add('PNG');
		fileType.add('JPEG');
		for (ContentDocumentLink conLink : contentDocumentLinkRecs){
			System.debug('conLink => ' + conLink);
			System.debug(fileType.contains(conLink.ContentDocument.fileType));
			// if (!fileType.contains(conLink.ContentDocument.fileType)){
			System.debug(productToDocumentMap.containsKey(conLink.LinkedEntityId));
			if (!productToDocumentMap.containsKey(conLink.LinkedEntityId)){
				productToDocumentMap.put(conLink.LinkedEntityId, new List<ContentDocumentLink>());
			}
			productToDocumentMap.get(conLink.LinkedEntityId).add(conLink);
			// }
			System.debug('productToDocumentMap => ' + productToDocumentMap);
		}
		List<String> imageIds = new List<String>();
		for (Question__c check : checks){
			if (check.buildertek__Image_Id__c != null && Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}').matcher(check.buildertek__Image_Id__c).matches()){
				imageIds.add(check.buildertek__Image_Id__c);
			}
		}

		Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>([SELECT Id, ContentDocumentId
		                                                                         FROM ContentVersion
		                                                                         WHERE ID In:imageIds]);
		List<Question__c> questionUpdate = new List<Question__c>();
		for (Question__c check : checks){
			if (check.buildertek__Image_Id__c != null){
				if (!Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}').matcher(check.buildertek__Image_Id__c).matches() || !contentVersionMap.containsKey(check.buildertek__Image_Id__c)){
					check.buildertek__Image_Id__c = '';
				}
			}
			questionDetails question = new questionDetails();
			question.check = check;

			for (String key : productToDocumentMap.keySet()){
				System.debug('key => ' + key);
				//Loop through list of accounts for each key
				System.debug('Value => ' + productToDocumentMap.get(key));
			}


			if (productToDocumentMap.containsKey(check.buildertek__Product__c)){
				question.contentDocumentLink = productToDocumentMap.get(check.buildertek__Product__c);
				System.debug('question.contentDocumentLink => ' + question.contentDocumentLink);
			}

			question.answerChoices = new List<answerChoice>();


			if (check.Choice_Template__c != null){
				String answerChoices = answerChoicesByChoiceTemplateId.Get(check.Choice_Template__c);
				if (!string.IsBlank(answerChoices)){
					for (string choice : answerChoices.split(', ')){
						answerChoice questionchoice = new answerChoice();
						questionchoice.label = choice;
						questionchoice.value = choice;
						question.answerChoices.add(questionchoice);
					}
				}
			} else if (!check.Answer_Choices__r.isEmpty()){
				for (Answer_Choice__c choice : check.Answer_Choices__r){
					if (choice.Choice_Text__c != null){
						answerChoice questionchoice = new answerChoice();
						questionchoice.label = choice.Choice_Text__c;
						questionchoice.value = choice.Choice_Text__c;
						question.answerChoices.add(questionchoice);
					}
				}
			}

			List<String> returnList = new List<String>();
			List<buildertek__Question__c> option = [SELECT Id, Name, buildertek__Product__c
			                                        FROM buildertek__Question__c
			                                        WHERE Id = :question.check.Id];

			System.debug('check doc id here ==> ' + option[0].buildertek__Product__c);
			if (option[0].buildertek__Product__c != null){
				List<ContentDocumentLink> contentLinkList = [SELECT Id, ContentDocumentId, LinkedEntityId
				                                             FROM ContentDocumentLink
				                                             WHERE LinkedEntityId = :option[0].buildertek__Product__c];
				System.debug('contentLinkList => ' + contentLinkList);
				if (contentLinkList.size() > 0){
					for (ContentDocumentLink link : contentLinkList){
						returnList.add(link.ContentDocumentId);
					}
				}
			}

			//         System.debug('There Are No Files');
			//         returnList.add('Error');
			//         returnList.add('There Are No Files');
			//         return returnList;
			//     }
			// } else{
			//     System.debug('There Are No Product');
			//     returnList.add('Error');
			//     returnList.add('There Are No Product');
			//     return returnList;


			// } catch (Exception e) {
			//     System.debug('Error => '+e.getMessage());
			//     returnList.add('Error');
			//     returnList.add(e.getMessage());
			//     return returnList;
			// }

			System.debug('*** question *** ' + question);
			// questions.add(returnList);
			questions.add(question);
			question.otherDetailsfields = otherfields;
		}
		return questions;
	}

	private static Map<Id, String> fillMapOfChoiceTemplateAnswerChoices(Set<Id> setChoiceTemplateIds){
		Map<Id, String> mapChoiceTemplateId_AnswerChoices = New Map<Id, String>();
		for (Choice_Template__c objChoiceTemplate : [SELECT Id, Name, (SELECT Id, Name, Choice_Template__c, Choice_Text__c
		                                                               FROM Answer_Choices__r
		                                                               ORDER BY Sort_Id__c, Name)
		                                             FROM Choice_Template__c
		                                             WHERE Name != 'System Internal Default Master' AND Id In:setChoiceTemplateIds]){

			String strAnswerChoices = '';
			for (Answer_Choice__c objAnswerChoice : objChoiceTemplate.Answer_Choices__r){
				if (objAnswerChoice.Choice_Text__c != null){
					if (strAnswerChoices == ''){
						strAnswerChoices += objAnswerChoice.Choice_Text__c;
					} else{
						strAnswerChoices += ', ' + objAnswerChoice.Choice_Text__c;
					}
				}
			}
			mapChoiceTemplateId_AnswerChoices.put(objChoiceTemplate.Id, strAnswerChoices);
		}
		return mapChoiceTemplateId_AnswerChoices;
	}

	/*@AuraEnabled
	 public static String deleteQuestionItem(String deleteAttributeItem){
	 if(String.isNotBlank(deleteAttributeItem)){
	 deleteAttributeItem=deleteAttributeItem.replace('[', '');
	 deleteAttributeItem=deleteAttributeItem.replace(']', '');
	 deleteAttributeItem=deleteAttributeItem.replace('"', '');
	 List<Id> lstString=new List<Id>();
	 if(deleteAttributeItem.contains(',')){
	 lstString = deleteAttributeItem.split(',');
	 }else{
	 lstString.add(deleteAttributeItem);
	 }
	 Set<Id> answerIds = new Set<Id>(lstString);
	 List<Answer_choice__c> attributeItemDelete = new List<Answer_choice__c>([Select Id FROM Answer_choice__c WHERE ID =: answerIds]);
	 if(attributeItemDelete.size()>0){
	 delete attributeItemDelete;
	 }
	 }
	 return 'success';
	 } */
	@AuraEnabled
	public static void updateQuestionGroup(String questions){
		System.debug('questions::' + questions);
		List<buildertek__Question__c> check = (List<buildertek__Question__c>)JSON.deserialize(questions, List<buildertek__Question__c>.class);

		DMLManager.updateAsUser(check);
		System.debug('CHECK' + check);
		//Integer a=1/0;
	}

	@AuraEnabled
	public static Map<String, List<String>> getAllProductAttributes(){
		Map<String, List<String>> productAttributes = new Map<String, List<String>>();
		productAttributes.put('Color', getProductColor());
		productAttributes.put('Finish', getProductFinish());
		productAttributes.put('Option', getProductOptionNumber());
		productAttributes.put('Category', getProductCategory());
		return productAttributes;
	}

	@AuraEnabled
	public static List<String> getProductColor(){
		List<String> pickListValuesList = new List<String>();
		//    Schema.DescribeFieldResult fieldResult = Product2.buildertek__Color__c.getDescribe();
		Schema.DescribeFieldResult fieldResult = Product2.buildertek__BT_COLOR__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}
		return pickListValuesList;
	}

	@AuraEnabled
	public static List<String> getProductFinish(){
		List<String> pickListValuesList = new List<String>();
		Schema.DescribeFieldResult fieldResult = Product2.buildertek__Finish__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}
		return pickListValuesList;
	}

	@AuraEnabled
	public static List<String> getProductOptionNumber(){
		List<String> pickListValuesList = new List<String>();
		Schema.DescribeFieldResult fieldResult = Product2.buildertek__Option_Number__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}
		return pickListValuesList;
	}

	@AuraEnabled
	public static List<String> getProductCategory(){
		List<String> pickListValuesList = new List<String>();
		Schema.DescribeFieldResult fieldResult = Product2.buildertek__Selection_Category__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}
		return pickListValuesList;
	}

	@AuraEnabled
	public static String addNewQuestion(String questionRecord, String choices){

		Question__c check = (Question__c)JSON.deserialize(questionRecord, Question__c.class);
		DMLManager.upsertAsUser(check);

		if (!String.IsBlank(choices)){
			List<Answer_Choice__c> answerChoices = (List<Answer_Choice__c>)System.JSON.deserialize(choices, List<Answer_Choice__c>.class);
			for (Answer_Choice__c ac : answerChoices){
				ac.Question__c = check.Id;
			}

			DMLManager.upsertAsUser(answerChoices);
			DMLManager.deleteAsUser([SELECT Id
			                         FROM Answer_Choice__c
			                         WHERE Question__c = :check.Id AND Id NOT IN:answerChoices]);


		}
		return 'success';
	}

	@AuraEnabled
	public static String addQuestion1(String questionRecord, String choices, String childChoicesLevelOne, String childChoicesLevelTwo, String childChoicesLevelThree){
		System.debug('Choices:1:' + childChoicesLevelOne);
		System.debug('Choices:2:' + childChoicesLevelTwo);
		System.debug('Choices:3:' + childChoicesLevelThree);

		Question__c check = (Question__c)JSON.deserialize(questionRecord, Question__c.class);
		DMLManager.upsertAsUser(check);

		if (!String.IsBlank(choices)){
			Map<Decimal, Answer_Choice__c> answerChoicesMap = new Map<Decimal, Answer_Choice__c>();
			Map<Decimal, Answer_Choice__c> answerChoicesMap2 = new Map<Decimal, Answer_Choice__c>();
			Map<Decimal, Answer_Choice__c> answerChoicesMap3 = new Map<Decimal, Answer_Choice__c>();
			Map<Decimal, Answer_Choice__c> answerChoicesMap4 = new Map<Decimal, Answer_Choice__c>();
			List<Answer_Choice__c> answerChoices = (List<Answer_Choice__c>)System.JSON.deserialize(choices, List<Answer_Choice__c>.class);

			for (Answer_Choice__c ac : answerChoices){
				ac.Question__c = check.Id;
				answerChoicesMap.put(ac.buildertek__Parent_Level__c, ac);
			}

			DMLManager.upsertAsUser(answerChoicesMap.values());

			if (String.isNotBlank(childChoicesLevelOne)){
				List<Answer_Choice__c> childAnswerChoices = (List<Answer_Choice__c>)System.JSON.deserialize(childChoicesLevelOne, List<Answer_Choice__c>.class);
				for (Answer_Choice__c ac : childAnswerChoices){
					ac.buildertek__ParentId__c = answerChoicesMap.get(ac.buildertek__Level__c).Id;
					ac.Question__c = check.Id;
					answerChoicesMap2.put(ac.buildertek__Parent_Level__c, ac);
				}
				upsert answerChoicesMap2.values();
				//DMLManager.upsertAsUser(answerChoicesMap2.values());
			}

			if (String.isNotBlank(childChoicesLevelTwo)){
				List<Answer_Choice__c> childAnswerChoices = (List<Answer_Choice__c>)System.JSON.deserialize(childChoicesLevelTwo, List<Answer_Choice__c>.class);
				for (Answer_Choice__c ac : childAnswerChoices){
					ac.buildertek__ParentId__c = answerChoicesMap2.get(ac.buildertek__Level__c).Id;
					ac.Question__c = check.Id;
					answerChoicesMap3.put(ac.buildertek__Parent_Level__c, ac);
				}
				upsert answerChoicesMap3.values();
				//DMLManager.upsertAsUser(answerChoicesMap3.values());
			}

			if (String.isNotBlank(childChoicesLevelThree)){
				List<Answer_Choice__c> childAnswerChoices = (List<Answer_Choice__c>)System.JSON.deserialize(childChoicesLevelThree, List<Answer_Choice__c>.class);
				for (Answer_Choice__c ac : childAnswerChoices){
					ac.buildertek__ParentId__c = answerChoicesMap3.get(ac.buildertek__Level__c).Id;
					ac.Question__c = check.Id;
					answerChoicesMap4.put(ac.buildertek__Parent_Level__c, ac);
				}
				upsert answerChoicesMap4.values();
			}
			answerChoicesMap3.putAll(answerChoicesMap);
			answerChoicesMap3.putAll(answerChoicesMap2);
			answerChoicesMap3.putAll(answerChoicesMap4);
			DMLManager.deleteAsUser([SELECT Id
			                         FROM Answer_Choice__c
			                         WHERE Question__c = :check.Id AND Id NOT IN:answerChoicesMap3.values()]);

		}
		return 'success';
	}

	@AuraEnabled
	public static String createChoices(String choices){

		List<Answer_Choice__c> answerChoices = (List<Answer_Choice__c>)System.JSON.deserialize(choices, List<Answer_Choice__c>.class);
		DMLManager.insertAsUser(answerChoices);
		system.debug('----choices----' + choices);
		return 'success';
	}

	@AuraEnabled
	public static String updateCitationOrder(List<Section__c> citations){
		try{
			DMLManager.updateAsUser(citations);
			return 'success';
		} catch (Exception ex){
			throw new AuraHandledException(ex.getMessage());
		}
	}

	@AuraEnabled
	public static String updateControlOrder(List<Question_Group__c> controls){
		try{
			DMLManager.updateAsUser(controls);
			return 'success';
		} catch (Exception ex){
			throw new AuraHandledException(ex.getMessage());
		}
	}

	@AuraEnabled
	public static void deleteRecord(String recordId){
		if (recordId != null && recordId.trim() != ''){
			deleteChildCitations(recordId);
			DMLManager.deleteAsUser([SELECT Id
			                         FROM Section__c
			                         WHERE Id = :recordId
			                         LIMIT 1]);
		}
	}

	@AuraEnabled
	public static void deleteControlRecord(String recordId){
		if (recordId != null && recordId.trim() != ''){
			DMLManager.deleteAsUser([SELECT Id
			                         FROM Question_Group__c
			                         WHERE Id = :recordId
			                         LIMIT 1]);
		}
	}

	@AuraEnabled
	public static void deleteCheckRecord(String checkId){
		if (checkId != null && checkId.trim() != ''){
			DMLManager.deleteAsUser([SELECT Id
			                         FROM Question__c
			                         WHERE Id = :checkId
			                         LIMIT 1]);
		}
	}

	private static void deleteChildCitations(String strCitationId){

		List<Section__c> listChildCitation = New List<Section__c>([SELECT Id, Parent__c
		                                                           FROM Section__c
		                                                           WHERE Parent__c != null AND Parent__c = :strCitationId]);

		List<Section__c> listDeleteChildCitation = New List<Section__c>();
		While (listChildCitation.size() > 0){

			Set<Id> setChildCitationId = New Set<Id>();
			for (Section__c objCitation : listChildCitation){
				setChildCitationId.Add(objCitation.Id);
				listDeleteChildCitation.Add(objCitation);
			}

			listChildCitation = New List<Section__c>([SELECT Id, Parent__c
			                                          FROM Section__c
			                                          WHERE Parent__c != null AND Parent__c IN:setChildCitationId]);
		}

		if (listDeleteChildCitation.size() > 0){
			DMLManager.deleteAsUser(listDeleteChildCitation);
		}
	}

	@AuraEnabled
	public static List<String> getObjectFieldSet(String fieldSetName, String objectName){
		List<String> objectFields = new List<String>();

		for (Schema.FieldSetMember fm : BT_Utils.getFieldSetMembers(fieldSetName, objectName)){
			objectFields.add(fm.getFieldPath());
		}
		return objectFields;
	}

	/**
	 * This method is used for Adding citation fields Like (Repository_Area__c, RecordTypeId etc)
	 * @param adId
	 */
	@AuraEnabled
	public static Section__c getSectionFields(Id adId){
		Section__c objCitation = new Section__c();
		objCitation.Selection__c = adId;
		return objCitation;
	}

	@AuraEnabled
	public static controlGroupDetails getControlDetails(String fieldSetName){
		String namespacePrefix = BT_Utils.getNamespacePrefix();

		controlGroupDetails controlDetail = new controlGroupDetails();
		controlDetail.namespacePrefix = namespacePrefix;

		for (Schema.FieldSetMember fm : BT_Utils.getFieldSetMembers(fieldSetName, BT_CONSTANTS.OBJECT_TYPE_QUESTION_GROUP)){
			String fieldAPIName = fm.getFieldPath();
			controlDetail.controlSetupFields.add(fieldAPIName);
		}

		return controlDetail;
	}

	@AuraEnabled
	public static testQuestionDetails getQuestionFieldSet(String fieldSetName){
		String namespacePrefix = BT_Utils.getNamespacePrefix();

		testQuestionDetails questionDetail = new testQuestionDetails();
		questionDetail.namespacePrefix = namespacePrefix;

		for (Schema.FieldSetMember fm : BT_Utils.getFieldSetMembers(fieldSetName, BT_CONSTANTS.OBJECT_TYPE_QUESTION)){
			String fieldAPIName = fm.getFieldPath();
			questionDetail.questionSetupFields.add(fieldAPIName);
		}

		return questionDetail;
	}

	@AuraEnabled
	public static List<File__c> getFiles(List<String> fileIds){
		List<file__c> filesList;
		if (Schema.sObjectType.file__c.fields.Id.isAccessible() && Schema.sObjectType.file__c.fields.Name.isAccessible()){

			filesList = [Select Id, Name
			             from file__c
			             where Id IN:fileIds];
		}
		return filesList;
	}

	public class citationDetails{
		@AuraEnabled
		public Map<Id, List<Section__c>> citationByParentId{ get; set; }

		@AuraEnabled
		public List<Section__c> citations{ get; set; }

		@AuraEnabled
		public List<String> sectionHeaderFields{ get; set; }

	}

	public class controlDetails{
		@AuraEnabled
		public Map<Id, List<Question_Group__c>> controlByParentId{ get; set; }

		@AuraEnabled
		public List<Question_Group__c> controls{ get; set; }

		@AuraEnabled
		public List<String> controlHeaderFields{ get; set; }

	}

	public class controlGroupDetails{
		@AuraEnabled
		public String namespacePrefix;

		@AuraEnabled
		public List<String> controlSetupFields{ get; set; }

		@AuraEnabled
		public List<String> controlAdvanceSettingFields{ get; set; }

		public controlGroupDetails(){
			controlSetupFields = new List<String>();
			controlAdvanceSettingFields = new List<String>();
			namespacePrefix = '';
		}

	}

	public class testQuestionDetails{
		@AuraEnabled
		public String namespacePrefix;

		@AuraEnabled
		public List<String> questionSetupFields{ get; set; }

		@AuraEnabled
		public List<String> questionAdvanceSettingFields{ get; set; }

		public testQuestionDetails(){
			questionSetupFields = new List<String>();
			questionAdvanceSettingFields = new List<String>();
			namespacePrefix = '';
		}

	}

	public class questionDetails{
		@AuraEnabled
		public Question__c check{ get; set; }

		@AuraEnabled
		public String errorMessage{ get; set; }

		@AuraEnabled
		public List<ContentDocumentLink> contentDocumentLink{ get; set; }

		@AuraEnabled
		public List<answerChoice> answerChoices{ get; set; }

		@AuraEnabled
		public List<fieldset> otherDetailsfields{ get; set; }

		@AuraEnabled
		public List<String> multiSelectChoiceValues{ get; set; }

		public questionDetails(){
			check = New Question__c();
			errorMessage = '';
			answerChoices = new List<answerChoice>();
			multiSelectChoiceValues = new List<String>();
			contentDocumentLink = new List<ContentDocumentLink>();
		}

	}

	/* all this classes are used for selection preview */
	@AuraEnabled
	public static testResult retrieveAllQuestionResults(String selectionSheetid, String sectionId){
		if (sectionId != null){
			String objName = String.valueOf(Id.valueOf(sectionId).getSObjectType());
			if (objName == 'buildertek__Question_Group__c'){
				buildertek__Question_Group__c secRec = [SELECT Id, buildertek__Section__c, buildertek__Is_Saved_Items__c
				                                        FROM buildertek__Question_Group__c
				                                        where id = :sectionId
				                                        LIMIT 1];
				if (secRec.buildertek__Section__c != null){
					sectionId = secRec.buildertek__Section__c;
				}
			}
		}
		testResult testResult = new testResult();

		testResult.selectionCatagorys = new List<selectionCatagory>();

		String query = 'Select ' + BT_Utils.getQueryStringForObjectWithAllFields('buildertek__Section__c');
		query = query + ', (Select ' + BT_Utils.getQueryStringForObjectWithAllFields('buildertek__Question_Group__c') + ' From Question_Groups__r ORDER BY Sort_Id__c, CreatedDate, Name ASC)';
		if (!String.isBlank(sectionId)){
			query = query + ' From buildertek__Section__c where Selection__c =:selectionSheetid AND Id =: sectionId ORDER BY Sort_Id__c, CreatedDate, Name ASC LIMIT 1';
		} else{
			query = query + ' From buildertek__Section__c where Selection__c =:selectionSheetid ORDER BY Sort_Id__c, CreatedDate, Name ASC LIMIT 1';
		}

		List<fieldset> otherQuestionFields = new List<fieldset>();
		for (Schema.FieldSetMember fm : BT_Utils.getFieldSetMembers('Section_Option_Addition_Fields', BT_CONSTANTS.OBJECT_TYPE_QUESTION)){
			fieldset fieldset = new fieldset();
			fieldset.fieldlabel = fm.getLabel();
			fieldset.fieldPath = fm.getFieldPath();
			fieldset.dataType = String.valueOf(fm.getType()).toUpperCase();
			otherQuestionFields.add(fieldset);
		}

		List<buildertek__Section__c> citaions;
		/*    if(Schema.sObjectType.buildertek__Section__c.fields.Id.isAccessible()
		 && Schema.sObjectType.buildertek__Section__c.fields.Name.isAccessible()
		 && Schema.sObjectType.buildertek__Section__c.fields.buildertek__Allowance__c.isAccessible()
		 && Schema.sObjectType.buildertek__Section__c.fields.buildertek__Date_Selected__c.isAccessible()
		 && Schema.sObjectType.buildertek__Section__c.fields.buildertek__Due_Date__c.isAccessible()
		 && Schema.sObjectType.buildertek__Section__c.fields.buildertek__Instructions__c.isAccessible()
		 && Schema.sObjectType.buildertek__Section__c.fields.buildertek__Locked__c.isAccessible()
		 && Schema.sObjectType.buildertek__Section__c.fields.buildertek__Parent__c.isAccessible()
		 && Schema.sObjectType.buildertek__Section__c.fields.buildertek__Selection__c.isAccessible()
		 && Schema.sObjectType.buildertek__Section__c.fields.buildertek__Sort_Id__c.isAccessible()
		 && Schema.sObjectType.buildertek__Section__c.fields.buildertek__Title__c.isAccessible()
		 && Schema.sObjectType.buildertek__Section__c.fields.buildertek__Total_Options__c.isAccessible()
		 && Schema.sObjectType.buildertek__Section__c.fields.buildertek__Total_Tested_Options__c.isAccessible()
		 && Schema.sObjectType.buildertek__Section__c.fields.buildertek__Visible_to_Customer__c.isAccessible()
		 && Schema.sObjectType.buildertek__Question_Group__c.fields.id.isAccessible()
		 && Schema.sObjectType.buildertek__Question_Group__c.fields.Name.isAccessible()
		 && Schema.sObjectType.buildertek__Question_Group__c.fields.buildertek__Parent__c.isAccessible()
		 && Schema.sObjectType.buildertek__Question_Group__c.fields.buildertek__Section__c.isAccessible()
		 && Schema.sObjectType.buildertek__Question_Group__c.fields.buildertek__Selected_By__c.isAccessible()
		 && Schema.sObjectType.buildertek__Question_Group__c.fields.buildertek__Sort_Id__c.isAccessible()
		 && Schema.sObjectType.buildertek__Question_Group__c.fields.buildertek__Title__c.isAccessible()

		 ){*/
		citaions = DataBase.Query(query);
		/* }*/
		System.debug('query ::: ' + query);
		System.debug('citaions ::: ' + JSON.serialize(citaions));
		set<Id> controlIds = new set<Id>();
		for (Section__c citation : citaions){
			for (Question_Group__c qg : citation.Question_Groups__r){
				controlIds.add(qg.Id);
			}
		}

		Map<Id, List<Question__c>> questionByControl = new Map<Id, List<Question__c>>();
		for (Question__c q : database.query('Select ' + BT_Utils.getQueryStringForObjectWithAllFields('buildertek__Question__c') + ',(SELECT Id,Name,Question__c,Drop_Down_Value__c,Choice_Value__c,buildertek__Text_Value__c,Choice_Text__c FROM Answer_Choices__r ORDER BY Sort_Id__c, CreatedDate, Name ASC), (Select ' + BT_Utils.getQueryStringForObjectWithAllFields('buildertek__Question_Result__c') + ' From Questions__r) from Question__c where Question_Group__c IN:controlIds ORDER BY Sort_Id__c, CreatedDate, Name ASC')){

			if (q.Question_Group__c != null){
				if (questionByControl.containsKey(q.Question_Group__c)){
					questionByControl.get(q.Question_Group__c).add(q);
				} else{
					questionByControl.put(q.Question_Group__c, new List<Question__c>{ q });
				}
			}

		}

		for (Section__c citation : citaions){

			selectionCatagory sc = new selectionCatagory();
			sc.selectionCatagory = citation;
			sc.selectionTypes = new List<selectionType>();

			for (Question_Group__c qg : citation.Question_Groups__r){
				selectionType st = new selectionType();
				System.debug('Question Group ::' + qg);
				st.selectionType = qg;

				st.selectionOptions = new List<selectionOption>();
				if (questionByControl.containsKey(qg.Id)){
					for (Question__c q : questionByControl.get(qg.Id)){

						selectionOption so = new selectionOption();
						so.check = q;
						so.multiSelectChoiceValues = new List<String>();
						if (!q.Questions__r.isEmpty()){
							so.checkResult = q.Questions__r[0];
							if (so.checkResult.Text_value__c == null)
								so.checkResult.Text_value__c = '';
						}

						so.answerChoices = new List<answerChoice>();

						for (Answer_Choice__c choice : q.Answer_Choices__r){
							if (choice.Choice_Text__c != null){
								answerChoice questionchoice = new answerChoice();
								questionchoice.label = choice.Choice_Text__c;
								questionchoice.value = choice.Id;
								so.answerChoices.add(questionchoice);
							}
						}
						so.otherDetailsfields = otherQuestionFields;
						st.selectionOptions.add(so);
					}
				}

				sc.selectionTypes.add(st);
			}

			testResult.selectionCatagorys.add(sc);

		}

		testResult.sectionCatagoryFields = new List<fieldset>();
		for (Schema.FieldSetMember fm : BT_Utils.getFieldSetMembers('Community_Header_FieldSet', BT_CONSTANTS.OBJECT_TYPE_SECTION)){
			fieldset fieldset = new fieldset();
			fieldset.fieldlabel = fm.getLabel();
			fieldset.fieldPath = fm.getFieldPath();
			fieldset.dataType = String.valueOf(fm.getType()).toUpperCase();
			testResult.sectionCatagoryFields.add(fieldset);
		}


		testResult.sectionTypeHeaderFields = new List<fieldset>();
		for (Schema.FieldSetMember fm : BT_Utils.getFieldSetMembers('Community_Header_FieldSet', BT_CONSTANTS.OBJECT_TYPE_QUESTION_GROUP)){
			fieldset fieldset = new fieldset();
			fieldset.fieldlabel = fm.getLabel();
			fieldset.fieldPath = fm.getFieldPath();
			fieldset.dataType = String.valueOf(fm.getType()).toUpperCase();
			testResult.sectionTypeHeaderFields.add(fieldset);
		}
		//Integer a =1/0;
		return testResult;
	}

	/*public static String setAllowance(String selectionSheetid, String sectionId){
	 if(String.isNotBlank(selectionSheetid)){
	 String query = 'Select Id, Name, buildertek__Allowance__c';
	 if(!String.isBlank(sectionId)) {
	 query = query + ' From buildertek__Section__c where Selection__c =:selectionSheetid AND Id =: sectionId ORDER BY Sort_Id__c, CreatedDate, Name ASC LIMIT 1';
	 } else {
	 query = query + ' From buildertek__Section__c where Selection__c =:selectionSheetid ORDER BY Sort_Id__c, CreatedDate, Name ASC LIMIT 1';
	 }
	 List<buildertek__Section__c> section;
	 section=DataBase.Query(query);
	 Set<Id> sectionIds =new Set<Id>();
	 Decimal allowance=0;
	 for(buildertek__Section__c s : section){
	 sectionIds.add(s.Id);
	 allowance=s.buildertek__Allowance__c;
	 }
	 String questionQuery= 'Select Id, Name,buildertek__Section__c, buildertek__Cost__c FROM buildertek__Question__c WHERE Section__c =:sectionIds';
	 List<buildertek__Question__c> question;
	 question=DataBase.Query(questionQuery);
	 Decimal sumOfAllQuestionCost=0;
	 for(buildertek__Question__c q:question){
	 sumOfAllQuestionCost+=q.buildertek__Cost__c==null?0:q.buildertek__Cost__c;
	 }
	 allowance=allowance-sumOfAllQuestionCost;
	 List<buildertek__Question_Group__c> questionGroup = [SELECT Id, Name, buildertek__Section__c, buildertek__Allowance_Available__c FROM buildertek__Question_Group__c
	 WHERE buildertek__Section__c=:sectionIds];
	 List<buildertek__Question_Group__c> questionsGroup =new List<buildertek__Question_Group__c>();
	 if(questionGroup.size()>0){
	 for(buildertek__Question_Group__c queGroup:questionGroup){
	 queGroup.Id=queGroup.Id;
	 queGroup.buildertek__Allowance_Available__c=allowance;
	 questionsGroup.add(queGroup);
	 }
	 update questionGroup;
	 }
	 }
	 return 'success';
	 }*/
	@AuraEnabled
	public static String getTreeQueryParamters(String selectionSheetId){
		return JSON.serialize(new Map<string, List<BT_TreeRemotingModel.QueryParameter>>{ 'buildertek__Section__c' => new List<BT_TreeRemotingModel.QueryParameter>{ new BT_TreeRemotingModel.QueryParameter('buildertek__Selection__c', selectionSheetId) } });
	}

	@AuraEnabled
	public static String getProjectName(String selectionSheetId){
		buildertek__Selection__c projectName = [SELECT Id, buildertek__Project__r.Name
		                                        FROM buildertek__Selection__c
		                                        where Id = :selectionSheetId];
		return projectName.buildertek__Project__r.Id;
	}

	@AuraEnabled
	public static selectionType submitSelectionType(Question_Group__c selectionType, List<buildertek__Question_Result__c> checkresult, List<buildertek__Answer_Choice__c> answerChoices){
		try{


			selectionType.Date_Selected__c = system.now();
			selectionType.buildertek__Locked__c = true;
			selectionType.Selected_by__c = userinfo.getuserId();
			if (Schema.sObjectType.Question_Group__c.fields.Date_Selected__c.isUpdateable() && Schema.sObjectType.Question_Group__c.fields.Selected_by__c.isUpdateable() && Schema.sObjectType.Question_Group__c.fields.Section__c.isUpdateable()){

				update selectionType;
			}
			List<Question_Group__c> questionGroups = [Select Id, Name, buildertek__Locked__c
			                                          From Question_Group__c
			                                          WHERE buildertek__Section__c = :selectionType.buildertek__Section__c];
			Integer countTrue = 0;
			Integer totalQuestionGroups = questionGroups.size();
			if (questionGroups.size() > 0){
				for (Question_Group__c questionGroup : questionGroups){
					if (questionGroup.buildertek__Locked__c){
						countTrue++;
					}
				}
			}
			if (selectionType.buildertek__Section__c != null){
				buildertek__Section__c sectionsingleRec = new buildertek__Section__c();
				sectionsingleRec.Id = selectionType.buildertek__Section__c;
				if (countTrue == totalQuestionGroups){
					sectionsingleRec.buildertek__Locked__c = true;
				} else{
					sectionsingleRec.buildertek__Locked__c = false;
				}
				sectionsingleRec.buildertek__Date_Selected__c = System.now().date();
				update sectionsingleRec;
			}
			if (Schema.sObjectType.buildertek__Answer_Choice__c.fields.Id.isUpdateable() && Schema.sObjectType.buildertek__Answer_Choice__c.fields.buildertek__Allow_Text_Entry__c.isUpdateable() && Schema.sObjectType.buildertek__Answer_Choice__c.fields.buildertek__Choice_Template__c.isUpdateable() && Schema.sObjectType.buildertek__Answer_Choice__c.fields.buildertek__Check_Result__c.isUpdateable() && Schema.sObjectType.buildertek__Answer_Choice__c.fields.buildertek__Choice_Text__c.isUpdateable() && Schema.sObjectType.buildertek__Answer_Choice__c.fields.buildertek__Choice_Value__c.isUpdateable() && Schema.sObjectType.buildertek__Answer_Choice__c.fields.Name.isUpdateable() && Schema.sObjectType.buildertek__Answer_Choice__c.fields.buildertek__Photo_Ids__c.isUpdateable() && Schema.sObjectType.buildertek__Answer_Choice__c.fields.buildertek__Question__c.isUpdateable() && Schema.sObjectType.buildertek__Answer_Choice__c.fields.buildertek__Sort_Id__c.isUpdateable()){
				update answerChoices;
			}
			if (Schema.sObjectType.buildertek__Question_Result__c.fields.Id.isUpdateable() && Schema.sObjectType.buildertek__Question_Result__c.fields.Name.isUpdateable() && Schema.sObjectType.buildertek__Question_Result__c.fields.buildertek__Selection_Category__c.isUpdateable() && Schema.sObjectType.buildertek__Question_Result__c.fields.buildertek__Question__c.isUpdateable() && Schema.sObjectType.buildertek__Question_Result__c.fields.buildertek__Tested__c.isUpdateable() && Schema.sObjectType.buildertek__Question_Result__c.fields.buildertek__Text_Value__c.isUpdateable()){
				update checkresult;
			}
			Question_Group__c qg;
			if (Schema.sObjectType.Question_Group__c.fields.Id.isAccessible() && Schema.sObjectType.Question_Group__c.fields.Section__c.isAccessible()){

				qg = [Select Id, Section__c
				      from Question_Group__c
				      where id = :selectionType.Id];
			}

			buildertek__Section__c section;
			if (Schema.sObjectType.buildertek__Section__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Section__c.fields.buildertek__Total_Tested_Options__c.isAccessible() && Schema.sObjectType.buildertek__Question_Result__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Question_Result__c.fields.buildertek__Tested__c.isAccessible() && Schema.sObjectType.buildertek__Question_Result__c.fields.buildertek__Selection_Category__c.isAccessible()){

				section = [Select Id, buildertek__Total_Tested_Options__c, (Select Id
				                                                            from buildertek__Selection_Option_Results__r
				                                                            where buildertek__Tested__c = true)
				           from buildertek__Section__c
				           where id = :qg.buildertek__Section__c];

			}
			section.buildertek__Total_Tested_Options__c = section.buildertek__Selection_Option_Results__r.size();
			if (Schema.sObjectType.buildertek__Section__c.fields.buildertek__Total_Tested_Options__c.isUpdateable()){
				update section;
			}
			return getQuestionGroupResultDetsils(qg.id);
		} catch (Exception ex){
			throw new AuraHandledException(ex.getMessage());
		}
	}

	public static selectionType getQuestionGroupResultDetsils(String questionGroupId){
		Map<Id, List<Question__c>> questionByControl = new Map<Id, List<Question__c>>();
		for (Question__c q : database.query('Select ' + BT_Utils.getQueryStringForObjectWithAllFields('buildertek__Question__c') + ',(SELECT Id,Name,Question__c,Choice_Text__c FROM Answer_Choices__r ORDER BY Sort_Id__c, CreatedDate, Name ASC), (Select ' + BT_Utils.getQueryStringForObjectWithAllFields('buildertek__Question_Result__c') + ' From Questions__r) from Question__c where Question_Group__c =:questionGroupId ORDER BY Sort_Id__c, CreatedDate, Name ASC')){

			if (q.Question_Group__c != null){
				if (questionByControl.containsKey(q.Question_Group__c)){
					questionByControl.get(q.Question_Group__c).add(q);
				} else{
					questionByControl.put(q.Question_Group__c, new List<Question__c>{ q });
				}
			}

		}

		List<fieldset> otherQuestionFields = new List<fieldset>();
		for (Schema.FieldSetMember fm : BT_Utils.getFieldSetMembers('Section_Option_Addition_Fields', BT_CONSTANTS.OBJECT_TYPE_QUESTION)){
			fieldset fieldset = new fieldset();
			fieldset.fieldlabel = fm.getLabel();
			fieldset.fieldPath = fm.getFieldPath();
			fieldset.dataType = String.valueOf(fm.getType()).toUpperCase();
			otherQuestionFields.add(fieldset);
		}


		selectionType st = new selectionType();
		for (Question_Group__c qg : Database.query('Select ' + BT_Utils.getQueryStringForObjectWithAllFields('buildertek__Question_Group__c') + ' From buildertek__Question_Group__c where Id =:questionGroupId')){
			st.selectionType = qg;
			st.selectionOptions = new List<selectionOption>();
			if (questionByControl.containsKey(qg.Id)){
				for (Question__c q : questionByControl.get(qg.Id)){

					selectionOption so = new selectionOption();
					so.check = q;
					so.multiSelectChoiceValues = new List<String>();
					if (!q.Questions__r.isEmpty()){
						so.checkResult = q.Questions__r[0];
						if (so.checkResult.Text_value__c == null)
							so.checkResult.Text_value__c = '';
					}

					so.answerChoices = new List<answerChoice>();

					for (Answer_Choice__c choice : q.Answer_Choices__r){
						if (choice.Choice_Text__c != null){
							answerChoice questionchoice = new answerChoice();
							questionchoice.label = choice.Choice_Text__c;
							questionchoice.value = choice.Id;
							so.answerChoices.add(questionchoice);
						}
					}
					so.otherDetailsfields = otherQuestionFields;
					st.selectionOptions.add(so);
				}
			}
		}

		return st;
	}

	@AuraEnabled
	public static Boolean getChangeOrderIdExist(String projectId, String optionName){
		buildertek__Change_Order__c CO = [SELECT Id, Name, buildertek__Project__c
		                                  FROM buildertek__Change_Order__c
		                                  WHERE buildertek__Project__c = :projectId AND Name = :optionName];
		if (String.isNotBlank(CO.buildertek__Project__c) && String.isNotBlank(CO.Name)){
			return true;
		}
		return false;
	}

	@AuraEnabled
	public static void createChangeOrder(String optionName, String projectName, String optionOverage){
		buildertek__Change_Order__c co = new buildertek__Change_Order__c();
		co.Name = 'Selection Overage for' + ' ' + optionName;
		co.buildertek__Status__c = 'Pending';
		co.buildertek__Type__c = 'Customer';
		co.buildertek__Project__c = projectName;
		insert co;
		buildertek__Change_Order_Item__c coi = new buildertek__Change_Order_Item__c();
		coi.Name = optionName;
		coi.buildertek__Quantity__c = 1;
		coi.buildertek__Unit_Price__c = Decimal.valueof(optionOverage);
		coi.buildertek__Change_Order__c = co.Id;
		insert coi;
	}

	public class testResult{
		@AuraEnabled
		public List<selectionCatagory> selectionCatagorys{ get; set; }

		@AuraEnabled
		public List<fieldset> sectionCatagoryFields{ get; set; }

		@AuraEnabled
		public List<fieldset> sectionTypeHeaderFields{ get; set; }

		@AuraEnabled
		public List<fieldset> sectionOptionHeaderFields{ get; set; }

	}

	public class selectionCatagory{
		@AuraEnabled
		public Section__c selectionCatagory{ get; set; }

		@AuraEnabled
		public List<selectionType> selectionTypes{ get; set; }

	}

	public class selectionType{
		@AuraEnabled
		public Question_Group__c selectionType{ get; set; }

		@AuraEnabled
		public List<selectionOption> selectionOptions{ get; set; }

	}

	public class selectionOption{
		@AuraEnabled
		public Question__c check{ get; set; }

		@AuraEnabled
		public Question_Result__c checkResult{ get; set; }

		@AuraEnabled
		public List<answerChoice> answerChoices{ get; set; }

		@AuraEnabled
		public List<String> multiSelectChoiceValues{ get; set; }

		@AuraEnabled
		public String errorMessage{ get; set; }

		@AuraEnabled
		public List<fieldset> otherDetailsfields{ get; set; }

		public selectionOption(){
			check = New Question__c();
			checkResult = new Question_Result__c();
			answerChoices = new List<answerChoice>();
			multiSelectChoiceValues = new List<String>();
			errorMessage = '';
		}

	}

	public class answerChoice{
		@AuraEnabled
		public string label;
		@AuraEnabled
		public string value;
	}

	public class fieldset{
		@AuraEnabled
		public string fieldlabel;
		@AuraEnabled
		public string fieldPath;
		@AuraEnabled
		public string dataType;
	}

	public class QuestionData{
		@AuraEnabled
		public PriceBookEntry PriceBookEntry;
		@AuraEnabled
		public String documentId;
		@AuraEnabled
		public String imageId;

	}

}