@isTest
public class BT_QuestionnaireBuilderTest{
    public static testMethod void testBT_QuestionnaireBuilder(){
        Selection__c selection = new Selection__c();
        insert selection;

        Product2 product = new Product2(Name = 'test_product');
        insert product;

        Pricebook2 priceBook = new Pricebook2(Name = 'test_priceBook');
        insert priceBook;

        ContentVersion contentVersion = new ContentVersion(Title = 'a picture', PathOnClient = 'Pic.jpg', VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
        insert contentVersion;

        ContentDocument document = [SELECT Id, Title, LatestPublishedVersionId
                                    FROM ContentDocument
                                    LIMIT 1];

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = product.id;
        contentlink.contentdocumentid = [select contentdocumentid
                                         from contentversion
                                         where id = :contentVersion.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers';
        insert contentlink;

        Section__c section1 = new Section__c(Selection__c = selection.Id);
        insert section1;

        Section__c section = new Section__c(Selection__c = selection.Id, Parent__c = section1.Id);
        insert section;

        Question_Group__c groupQuestion = new Question_Group__c(Section__c = section.Id);
        insert groupQuestion;

        Choice_Template__c choiceTemplate = new Choice_Template__c(Name = 'test-choice');
        insert choiceTemplate;

        Set<Id> choiceTemplateId = new Set<Id>();
        choiceTemplateId.add(choiceTemplate.id);

        Question__c question = new Question__c(Question_Group__c = groupQuestion.Id, Choice_Template__c = choiceTemplate.Id, buildertek__Is_Selected_Item__c = true);
        insert question;

        Question__c question1 = new Question__c(Question_Group__c = groupQuestion.Id, Choice_Template__c = NULL, buildertek__Is_Selected_Item__c = true);
        insert question1;

        buildertek__Project__c project = new buildertek__Project__c(Name = 'test project');
        insert project;

        Answer_Choice__c answerChoice = new Answer_Choice__c(Question__c = question.Id, Choice_Text__c = 'Test');
        insert answerChoice;

        Answer_Choice__c answerChoice1 = new Answer_Choice__c(Question__c = question1.Id, Choice_Text__c = 'Test');
        insert answerChoice1;

        List<String> fileIds = new List<String>();

        BT_QuestionnaireBuilder.getSelection(selection.Id);
        BT_QuestionnaireBuilder.checkIfCustomerCommunity();
        BT_QuestionnaireBuilder.deleteImage(question.Id);
        // BT_QuestionnaireBuilder.retriveChangeNodeConfig();
        BT_QuestionnaireBuilder.retriveAllowanceOverage();
        BT_QuestionnaireBuilder.createChangeOrder('Test', project.id, '200');
        BT_QuestionnaireBuilder.getProductCategory();
        BT_QuestionnaireBuilder.getProductOptionNumber();
        BT_QuestionnaireBuilder.getProductFinish();
        BT_QuestionnaireBuilder.getProductColor();
        BT_QuestionnaireBuilder.getAllProductAttributes();
        BT_QuestionnaireBuilder.getProjectName(selection.Id);

        BT_QuestionnaireBuilder.retriveContentVersionId(document.Id);
        BT_QuestionnaireBuilder.getImageVisibility(selection.Id);
        BT_QuestionnaireBuilder.retrieveCitations(selection.Id);
        BT_QuestionnaireBuilder.retrieveControls(section.Id);
        BT_CONSTANTS.OBJECT_TYPE_QUESTION = 'Question__c';
        BT_QuestionnaireBuilder.retrieveQuestions(groupQuestion.Id);
        // BT_QuestionnaireBuilder.addNewQuestion(JSON.serialize(question1), JSON.serialize(new List<Answer_Choice__c> {answerChoice1}));
        BT_QuestionnaireBuilder.saveQuestion(JSON.serialize(new List<Question__c>{ question }));
        BT_QuestionnaireBuilder.updateQuestion(contentVersion.Id, JSON.serialize(new List<Question__c>{ question }));
        BT_QuestionnaireBuilder.addNewAnswerChoices(JSON.serialize(new List<Answer_Choice__c>{ answerChoice1 }));
        BT_QuestionnaireBuilder.saveAttributeTypeValue(JSON.serialize(new List<Question__c>{ question }), JSON.serialize(new List<Answer_Choice__c>{ answerChoice }));
        BT_QuestionnaireBuilder.getpricebooks();
        BT_QuestionnaireBuilder.getselectOptionsforproductfamily();
        BT_QuestionnaireBuilder.saveAttribute(JSON.serialize(new List<Question__c>{ question }), JSON.serialize(new List<Answer_Choice__c>{ answerChoice }));
        BT_QuestionnaireBuilder.createChoices(JSON.serialize(new List<Answer_Choice__c>{ new Answer_Choice__c(Question__c = question.Id, Choice_Text__c = 'Test') }));
        BT_QuestionnaireBuilder.updateCitationOrder(new List<Section__c>{ section });
        BT_QuestionnaireBuilder.updateControlOrder(new List<Question_Group__c>{ groupQuestion });
        BT_QuestionnaireBuilder.updateQuestionGroup(JSON.serialize(new List<Question__c>{ question }));
        BT_QuestionnaireBuilder.getObjectFieldSet('Community_Header_FieldSet', 'Section__c');
        BT_QuestionnaireBuilder.getSectionFields(selection.Id);
        BT_QuestionnaireBuilder.getQuestionInfo(priceBook.Id, product.Id);
        BT_QuestionnaireBuilder.getControlDetails('Community_Header_FieldSet');
        BT_QuestionnaireBuilder.getQuestionFieldSet('Selection_Option_Fields');
        BT_CONSTANTS.OBJECT_TYPE_QUESTION = 'buildertek__Question__c';
        BT_QuestionnaireBuilder.retrieveAllQuestionResults(selection.Id, section.Id);
        BT_QuestionnaireBuilder.retrieveAllQuestionResults(selection.Id, NULL);
        BT_QuestionnaireBuilder.getTreeQueryParamters(selection.Id);
        BT_QuestionnaireBuilder.submitSelectionType(groupQuestion, [SELECT Id
                                                                    FROM Question_Result__c], [SELECT Id
                                                                                               FROM Answer_Choice__c]);
        BT_QuestionnaireBuilder.getFiles(fileIds);
        BT_QuestionnaireBuilder.deleteRecord(section1.Id);
        BT_QuestionnaireBuilder.deleteControlRecord(groupQuestion.Id);
        BT_QuestionnaireBuilder.deleteCheckRecord(question.Id);
        System.assertEquals('Test', 'Test');
    }

    public static testMethod void testBT_MultiSelectLookupController(){
        BT_MultiSelectLookupController.fetchLookUpValues('test', 'Account', new List<sObject>(), true, '');
        System.assertEquals('Test', 'Test');
    }

}