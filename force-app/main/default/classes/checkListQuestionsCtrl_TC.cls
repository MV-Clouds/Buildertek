@isTest
public class checkListQuestionsCtrl_TC {
    @isTest
    public static void testchecklistquestion(){
        Account Acc = new Account();
        Acc.Name = 'Test Account';
        insert Acc;
        
         contact con = new contact();
        con.lastName= 'Test Account';
        con.Email = 'Test@gmail.com';
        con.AccountId = Acc.Id;
        insert con;   
        
        buildertek__Checklist_Objects__c bdchecklist=new buildertek__Checklist_Objects__c();
        bdchecklist.name='Checklist Logo';
            insert bdchecklist;
        Attachment att=new Attachment();
        att.ParentId=bdchecklist.Id;
        att.Name='ChecklistLogo';
        att.Body=Blob.valueof('/services/data/v52.0/sobjects/Attachment/00P1K00000raoBRUAY/Body');
        insert att;
        
        buildertek__Checklist_Configuration__c btcheckconfig = new buildertek__Checklist_Configuration__c();
        btcheckconfig.Name = 'Contact checklist';
        btcheckconfig.buildertek__Object_Name__c = 'Contact';
        insert btcheckconfig;
        
        buildertek__Questions__c btquestion = new buildertek__Questions__c();
        btquestion.buildertek__Customize__c = 'How are you?';
        btquestion.buildertek__Options__c  = 'ok';
        btquestion.buildertek__Question_Type__c = 'Single Select Answer';
        btquestion.buildertek__Options__c='Single Select option';
        insert btquestion;
        
        
        buildertek__Checklist_Questions__c bdcheckquestion=new buildertek__Checklist_Questions__c();
        
        bdcheckquestion.buildertek__Checklist_Configuration__c=btcheckconfig.Id;
        bdcheckquestion.buildertek__Questions__c=btquestion.id;
        //bdcheckquestion.buildertek__Questions__r.buildertek__Options__c='Single Select option';
        insert bdcheckquestion;
        
        buildertek__MSA_Settings__c msasettings=new buildertek__MSA_Settings__c();
        msasettings.name='MSA Settings';
         msasettings.buildertek__Site_URL__c='https://builderteklightning-developer-edition.na75.force.com/';
         insert msasettings;
        
        checkListQuestionsCtrl.ObjectClass objclass=new  checkListQuestionsCtrl.ObjectClass();
        objclass.Id=bdcheckquestion.Id;
        objclass.Name='test';
        objclass.ObjectName='buildertek__Checklist_Questions__c';
        
        checkListQuestionsCtrl.ObjectWrapper objwrapper=new checkListQuestionsCtrl.ObjectWrapper();
        objwrapper.APIName='buildertek__Checklist_Questions__c';
        objwrapper.Label='string';
        objwrapper.LookUpAPIName='buildertek__Questions__c';
        
        checkListQuestionsCtrl.ResultWrapper rewrapper=new checkListQuestionsCtrl.ResultWrapper();
        rewrapper.IsSuccess=True;
        rewrapper.Message='test class checking';
        list<checkListQuestionsCtrl.ObjectWrapper> wraplist=new list<checkListQuestionsCtrl.ObjectWrapper>();
        wraplist.add(objwrapper);
        rewrapper.WrapperList=wraplist;
        
        checkListQuestionsCtrl.QuestionOption qsoptions=new checkListQuestionsCtrl.QuestionOption();
        qsoptions.label='test';
        qsoptions.value='test';
        
        
        
        checkListQuestionsCtrl.QuestionsInnerclass qinclass=new checkListQuestionsCtrl.QuestionsInnerclass();
        qinclass.QuestionId=btquestion.id;
        qinclass.QuestionName=btquestion.Name;
        qinclass.QuestionType='Single Select Answer';
        qinclass.QuestionValue='test';
        list<string> qpoption=new List<string>();
        qpoption.add('test');
        list<checkListQuestionsCtrl.QuestionOption> qsoptionlist=new list<checkListQuestionsCtrl.QuestionOption>();
        qsoptionlist.add(qsoptions);
        qinclass.QuestionOptions=qsoptionlist;
        qinclass.QuestionValues=qpoption;
        List<checkListQuestionsCtrl.QuestionsInnerclass> qinclasslist=new list<checkListQuestionsCtrl.QuestionsInnerclass>();
        qinclasslist.add(qinclass);
        //string questionstring=system.JSON.deserialize('text',checkListQuestionsCtrl.QuestionsInnerclass);
        string qstring = JSON.serialize(qinclasslist);
        
        system.debug('&&&&&&'+qstring );
        checkListQuestionsCtrl.getAttachmentData();
        checkListQuestionsCtrl.getCheckListConfigurationData(con.id);
        checkListQuestionsCtrl.getQuestions(btcheckconfig.id);
        //checkListQuestionsCtrl.sendchecklist(btcheckconfig.Id, con.Id, 'teast@test.com', 'Email ', True,'Account','test','{!URL}','test');
        //checkListQuestionsCtrl.sendchecklist(btcheckconfig.Id, con.Id, 'teast@test.com', 'Email', false,'Account','test','{!URL}','test');
        checkListQuestionsCtrl.getObjectLabelName('buildertek__Checklist_Configuration__c');
        checkListQuestionsCtrl.getinitialObjectFields('buildertek__Checklist_Configuration__c');
        checkListQuestionsCtrl.getAllObjectFields('buildertek__Checklist_Configuration__c');
        checkListQuestionsCtrl.GetSecLevelFieldDetailscontroller('buildertek__Checklist_Questions__c' , 'buildertek__Checklist_Configuration__c', 'buildertek__Questions__c');
        //checkListQuestionsCtrl.createchecklistquestion(JSON.serialize(checkListQuestionsCtrl.getQuestions(btcheckconfig.id)), btquestion.Id);
        checkListQuestionsCtrl.createchecklistquestion(qstring , con.Id, 'Test');
        checkListQuestionsCtrl.GetFieldDetails('buildertek__Checklist_Configuration__c' , 'buildertek__Questions__c');
        checkListQuestionsCtrl.getEmailFieldsList(con.id);
        
    }
}