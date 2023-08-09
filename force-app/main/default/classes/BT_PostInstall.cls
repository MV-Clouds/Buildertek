public class BT_PostInstall {
    
    public static string ICON_URL = '/resource/buildertek__SLDS/assets/icons/utility/settings_60.png';
    
    public static void createAdminInterfaceNodeConfigurations(){
        
        List<buildertek__Admin_Interface_Node_Configuration__c> adminConfigurationList = New List<buildertek__Admin_Interface_Node_Configuration__c>();
        List<buildertek__Admin_Interface_Node_Configuration__c> childAdminConfigurationList = New List<buildertek__Admin_Interface_Node_Configuration__c>();
        
        /*SELECT Id, Name, buildertek__Description__c, buildertek__Icon_URL__c, buildertek__Index__c, buildertek__Open_New_Tab__c, buildertek__Page_URL__c, 
        buildertek__Parent_Node__c, buildertek__Tab_Name__c, buildertek__Change_Order_Configuration__c, buildertek__Quote_Configuration__c, buildertek__Email_Subject__c, 
        buildertek__Retreive_Aerial_Photo_of_project__c,  buildertek__Create_Budget_on_Quote_Acceptance__c,  buildertek__Create_Project_from_Opportunity__c, 
        buildertek__Send_PO_On_Approval__c, buildertek__Automatically_add_Expense_to_Budget__c, buildertek__Automatically_add_Time_Card_to_Budget__c, 
        buildertek__Update_the_Opp_Amount__c, buildertek__Send_Vendor_Lien_Release_On_Approval__c FROM buildertek__Admin_Interface_Node_Configuration__c*/


        buildertek__Admin_Interface_Node_Configuration__c BOMLineSettings = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'BOM Line Settings',
                                                                                                                                  buildertek__Tab_Name__c = 'BOM Line Settings',
                                                                                                                                  buildertek__Description__c = 'Configure BOM Line Process for your organization.',
                                                                                                                                  buildertek__Index__c = 18,
                                                                                                                                  buildertek__Icon_URL__c = ICON_URL,
                                                                                                                                  buildertek__Page_URL__c = '/apex/BOMLineSettings');
        adminConfigurationList.add(BOMLineSettings);
        
        buildertek__Admin_Interface_Node_Configuration__c BOMSettings = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'BOM Settings',
                                                                                                                              buildertek__Tab_Name__c = 'BOM Settings',
                                                                                                                              buildertek__Description__c = 'Configure BOM Process for your organization.',
                                                                                                                              buildertek__Index__c = 16,
                                                                                                                              buildertek__Icon_URL__c = ICON_URL,
                                                                                                                              buildertek__Page_URL__c = '/apex/buildertek__BOMSettings');
        adminConfigurationList.add(BOMSettings);
        
        buildertek__Admin_Interface_Node_Configuration__c BOXSettings = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'BOX Settings',
                                                                                                                              buildertek__Tab_Name__c = 'BOX Settings',
                                                                                                                              buildertek__Icon_URL__c = ICON_URL);
        adminConfigurationList.add(BOXSettings);
        
        /*-----------------------------------------------------------------------------------------------------------------------------*/
        
          buildertek__Admin_Interface_Node_Configuration__c Box1Settings = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Box Settings',
                                                                                                                                  buildertek__Tab_Name__c = 'Box Settings',
                                                                                                                                  buildertek__Icon_URL__c = ICON_URL);
        adminConfigurationList.add(Box1Settings);
        
        
           buildertek__Admin_Interface_Node_Configuration__c BTAccountPayableConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'BT Account Payable Configuration',
                                                                                                                                  buildertek__Tab_Name__c = 'BT Account Payable Configuration',
                                                                                                                                  buildertek__Description__c = 'Configure Account Payable Process for your organization.',
                                                                                                                                  buildertek__Index__c = 12,
                                                                                                                                  buildertek__Icon_URL__c = ICON_URL);
        adminConfigurationList.add(BTAccountPayableConfiguration);
        
         buildertek__Admin_Interface_Node_Configuration__c BTBudgetConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'BT Budget Configuration',
                                                                                                                                  buildertek__Tab_Name__c = 'BT Budget Configuration',
                                                                                                                                  buildertek__Description__c = 'Configure Budget Process for your organization.',
                                                                                                                                  buildertek__Index__c = 4,
                                                                                                                                  buildertek__Icon_URL__c = ICON_URL);
                                                                                                                              
        adminConfigurationList.add(BTBudgetConfiguration);
        
          buildertek__Admin_Interface_Node_Configuration__c BTChangeOrderConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'BT Change Order Configuration',
                                                                                                                                  buildertek__Tab_Name__c = 'BT Change Order Configuration',
                                                                                                                                  buildertek__Description__c = 'Configure Change Order Process for your organization.',
                                                                                                                                  buildertek__Index__c = 6,
                                                                                                                                  buildertek__Icon_URL__c = ICON_URL);
                                                                                                                                 
        adminConfigurationList.add(BTChangeOrderConfiguration);
        
         buildertek__Admin_Interface_Node_Configuration__c BTContractConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'BT Contract Configuration',
                                                                                                                                  buildertek__Tab_Name__c = 'BT Contract Configuration',
                                                                                                                                  buildertek__Description__c = 'Configure Contract Process for your organization.',
                                                                                                                                  buildertek__Index__c = 3,
                                                                                                                                  buildertek__Icon_URL__c = ICON_URL);
                                                                                                                               
        adminConfigurationList.add(BTContractConfiguration);
        
         buildertek__Admin_Interface_Node_Configuration__c BTDocumentConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'BT Document Configuration',
                                                                                                                                  buildertek__Tab_Name__c = 'BT Document Configuration',
                                                                                                                                  buildertek__Description__c = 'Configure Document Interface for your organization.',
                                                                                                                                  buildertek__Index__c = 8,
                                                                                                                                  buildertek__Icon_URL__c = ICON_URL);
                                                                                                                              
        adminConfigurationList.add(BTDocumentConfiguration);
        
         buildertek__Admin_Interface_Node_Configuration__c BTOpportunityConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'BT Opportunity Configuration',
                                                                                                                                  buildertek__Tab_Name__c = 'BT Opportunity Configuration',
                                                                                                                                  buildertek__Description__c = 'Configure Opportunity Process for your organization.',
                                                                                                                                  buildertek__Index__c = 11,
                                                                                                                                  buildertek__Icon_URL__c = ICON_URL);
                                                                                                                              
        adminConfigurationList.add(BTOpportunityConfiguration);
        
          buildertek__Admin_Interface_Node_Configuration__c BTPaymentApplicationConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'BT Payment Application Configuration',
                                                                                                                                  buildertek__Tab_Name__c = 'BT Payment Application Configuration',
                                                                                                                                  buildertek__Description__c = 'Configure Payment Application Process for your organization.',
                                                                                                                                  buildertek__Index__c = 18,
                                                                                                                                  buildertek__Icon_URL__c = ICON_URL);
                                                                                                                              
        adminConfigurationList.add(BTPaymentApplicationConfiguration);
        
          buildertek__Admin_Interface_Node_Configuration__c BTPreQualificationConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'BT Pre Qualification Configuration',
                                                                                                                                  buildertek__Tab_Name__c = 'BT Pre Qualification Configuration',
                                                                                                                                  buildertek__Index__c = 14,
                                                                                                                                  buildertek__Icon_URL__c = ICON_URL);
                                                                                                                              
        adminConfigurationList.add(BTPreQualificationConfiguration);
        
          buildertek__Admin_Interface_Node_Configuration__c BTProjectConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'BT Project Configuration',
                                                                                                                                  buildertek__Tab_Name__c = 'BT Project Configuration',
                                                                                                                                  buildertek__Description__c = 'Configure Project Process for your organization.',
                                                                                                                                  buildertek__Index__c = 1,
                                                                                                                                  buildertek__Icon_URL__c = ICON_URL);
                                                                                                                              
        adminConfigurationList.add(BTProjectConfiguration);
        
           buildertek__Admin_Interface_Node_Configuration__c BTPurchaseOrderConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'BT Purchase Order Configuration',
                                                                                                                                  buildertek__Tab_Name__c = 'BT Purchase Order Configuration',
                                                                                                                                  buildertek__Description__c = 'Configure Purchase Order Process for your organization.',
                                                                                                                                  buildertek__Index__c = 5,
                                                                                                                                  buildertek__Icon_URL__c = ICON_URL);
                                                                                                                              
        adminConfigurationList.add(BTPurchaseOrderConfiguration);
        
          buildertek__Admin_Interface_Node_Configuration__c BTQuoteConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'BT Quote Configuration',
                                                                                                                                  buildertek__Tab_Name__c = 'BT Quote Configuration',
                                                                                                                                  buildertek__Description__c = 'Configure Quote Process for your organization.',
                                                                                                                                  buildertek__Index__c = 3,
                                                                                                                                  buildertek__Icon_URL__c = ICON_URL);
                                                                                                                              
        adminConfigurationList.add(BTQuoteConfiguration);
        
          buildertek__Admin_Interface_Node_Configuration__c BTRFIConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'BT RFI Configuration',
                                                                                                                                  buildertek__Tab_Name__c = 'BT RFI Configuration',
                                                                                                                                  buildertek__Description__c = 'Configure RFI Process for your organization.',
                                                                                                                                  buildertek__Index__c = 15,
                                                                                                                                  buildertek__Icon_URL__c = ICON_URL,
                                                                                                                                  buildertek__Page_URL__c = '/apex/buildertek__RFI_Settingsvf');
                                                                                                                              
        adminConfigurationList.add(BTRFIConfiguration);
        
          buildertek__Admin_Interface_Node_Configuration__c BTRFQConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'BT RFQ Configuration',
                                                                                                                                  buildertek__Tab_Name__c = 'BT RFQ Configuration',
                                                                                                                                  buildertek__Description__c = 'Configure RFQ Process for your organization.',
                                                                                                                                  buildertek__Index__c = 2,
                                                                                                                                  buildertek__Icon_URL__c = ICON_URL);
                                                                                                                              
        adminConfigurationList.add(BTRFQConfiguration);
        
         buildertek__Admin_Interface_Node_Configuration__c BTSOVConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'BT SOV Configuration',
                                                                                                                                  buildertek__Tab_Name__c = 'BT SOV Configuration',
                                                                                                                                  buildertek__Description__c = 'Configure SOV Process for your organization.',
                                                                                                                                  buildertek__Index__c = 17,
                                                                                                                                  buildertek__Icon_URL__c = ICON_URL);
                                                                                                                              
        adminConfigurationList.add(BTSOVConfiguration);
        
          buildertek__Admin_Interface_Node_Configuration__c BTTraining = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'BT Training',
                                                                                                                                  buildertek__Tab_Name__c = 'BT Training',
                                                                                                                                  buildertek__Description__c = 'Configure Training',
                                                                                                                                  buildertek__Index__c = 13,
                                                                                                                                  buildertek__Icon_URL__c = ICON_URL);
                                                                                                                              
        adminConfigurationList.add(BTTraining);
        
          buildertek__Admin_Interface_Node_Configuration__c BudgetConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Budget Configurations',
                                                                                                                              buildertek__Tab_Name__c = 'Budget Configuration',
                                                                                                                              buildertek__Icon_URL__c = ICON_URL);
        adminConfigurationList.add(BudgetConfiguration);
        
           buildertek__Admin_Interface_Node_Configuration__c ChangeOrderConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Change Order Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'Change Order Configuration',
                                                                                                                              buildertek__Icon_URL__c = ICON_URL);
        adminConfigurationList.add(ChangeOrderConfiguration);
        
           buildertek__Admin_Interface_Node_Configuration__c CreateAccount = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Create Account',
                                                                                                                              buildertek__Tab_Name__c = 'Create Account',
                                                                                                                               buildertek__Index__c = 13,
                                                                                                                                      buildertek__Description__c = 'Configure Accounts',
                                                                                                                              buildertek__Icon_URL__c = ICON_URL);
        adminConfigurationList.add(CreateAccount);
        
         buildertek__Admin_Interface_Node_Configuration__c CreateContact = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Create Contact',
                                                                                                                              buildertek__Tab_Name__c = 'Create Contact',
                                                                                                                               buildertek__Index__c = 13,
                                                                                                                                      buildertek__Description__c = 'Configure Contacts',
                                                                                                                              buildertek__Icon_URL__c = ICON_URL);
        adminConfigurationList.add(CreateContact);
        
          buildertek__Admin_Interface_Node_Configuration__c CreateContractonQuoteAcceptance = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Create Contract on Quote Acceptance',
                                                                                                                              buildertek__Tab_Name__c = 'Create Contract on Quote Acceptance',
                                                                                                                            //   buildertek__Index__c = 13,
                                                                                                                                  //    buildertek__Description__c = 'Configure Contacts',
                                                                                                                              buildertek__Icon_URL__c = ICON_URL);
        adminConfigurationList.add(CreateContractonQuoteAcceptance);
        
          buildertek__Admin_Interface_Node_Configuration__c CreatinganewUser = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Creating a new User',
                                                                                                                              buildertek__Tab_Name__c = 'Creating a new User',
                                                                                                                            //   buildertek__Index__c = 13,
                                                                                                                                   buildertek__Description__c = 'Configure creating new users',
                                                                                                                              buildertek__Icon_URL__c = ICON_URL);
        adminConfigurationList.add(CreatinganewUser);
        
          buildertek__Admin_Interface_Node_Configuration__c CreatingAccountsandContacts = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Creating Accounts and Contacts',
                                                                                                                              buildertek__Tab_Name__c = 'Creating Accounts and Contacts',
                                                                                                                               buildertek__Index__c = 13,
                                                                                                                                   buildertek__Description__c = 'Configure Accounts and Contacts',
                                                                                                                              buildertek__Icon_URL__c = ICON_URL);
        adminConfigurationList.add(CreatingAccountsandContacts);
        
          buildertek__Admin_Interface_Node_Configuration__c EmailConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Email Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'Email Configuration',
                                                                                                                               buildertek__Index__c = 19,
                                                                                                                                  // buildertek__Description__c = 'Configure Accounts and Contacts',
                                                                                                                              buildertek__Icon_URL__c = ICON_URL,
                                                                                                                                     buildertek__Page_URL__c =    '/apex/buildertek__BT_EmailConfiguration');
        adminConfigurationList.add(EmailConfiguration);
        
          buildertek__Admin_Interface_Node_Configuration__c FileExplorerPageConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'File Explorer Page Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'File Explorer Page Configuration',
                                                                                                                               buildertek__Index__c = 2,
                                                                                                                              buildertek__Description__c = 'Configure File Explorer Interface for your organization.',
                                                                                                                              buildertek__Icon_URL__c = ICON_URL);
                                                                                                                                   
        adminConfigurationList.add(FileExplorerPageConfiguration);
        
          buildertek__Admin_Interface_Node_Configuration__c FileUploadPageConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'File Upload Page Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'File Upload Page Configuration',
                                                                                                                               buildertek__Index__c = 3,
                                                                                                                              buildertek__Description__c = 'Configure default values for new file.',
                                                                                                                              buildertek__Icon_URL__c = ICON_URL);
                                                                                                                                   
        adminConfigurationList.add(FileUploadPageConfiguration);
        
          buildertek__Admin_Interface_Node_Configuration__c MSAConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'MSA Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'MSA Configuration',
                                                                                                                             buildertek__Icon_URL__c = ICON_URL,
                                                                                                                               buildertek__Index__c = 15);
                                                                                                                           
                                                                                                                                   
        adminConfigurationList.add(MSAConfiguration);
        
          buildertek__Admin_Interface_Node_Configuration__c MSA1Configuration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'MSA Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'MSA Configuration',
                                                                                                                             buildertek__Icon_URL__c = ICON_URL);
                                                                                                                               
                                                                                                                           
                                                                                                                                   
        adminConfigurationList.add(MSA1Configuration);
        
          buildertek__Admin_Interface_Node_Configuration__c OpportunityConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Opportunity Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'Opportunity Configuration',
                                                                                                                             buildertek__Icon_URL__c = ICON_URL);
                                                                                                                               
                                                                                                                           
                                                                                                                                   
        adminConfigurationList.add(OpportunityConfiguration);
        
          buildertek__Admin_Interface_Node_Configuration__c PaymentApplicationConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Payment Application Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'Payment Application Configuration',
                                                                                                                             buildertek__Icon_URL__c = ICON_URL);
                                                                                                                               
                                                                                                                           
                                                                                                                                   
        adminConfigurationList.add(PaymentApplicationConfiguration);
        
         buildertek__Admin_Interface_Node_Configuration__c PreQualificationConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Pre Qualification Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'Pre Qualification Configuration',
                                                                                                                             buildertek__Icon_URL__c = ICON_URL);
                                                                                                                               
                                                                                                                           
                                                                                                                                   
        adminConfigurationList.add(PreQualificationConfiguration);
        
          buildertek__Admin_Interface_Node_Configuration__c ProjectConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Project Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'Project Configuration',
                                                                                                                             buildertek__Icon_URL__c = ICON_URL);
                                                                                                                               
                                                                                                                           
                                                                                                                                   
        adminConfigurationList.add(ProjectConfiguration);
        
          buildertek__Admin_Interface_Node_Configuration__c PurchaseOrderConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Purchase Order Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'Purchase Order Configuration',
                                                                                                                                buildertek__Description__c = 'Use to send email on PO Approved.',
                                                                                                                             buildertek__Icon_URL__c = ICON_URL);
                                                                                                                               
                                                                                                                           
                                                                                                                                   
        adminConfigurationList.add(PurchaseOrderConfiguration);
        
         buildertek__Admin_Interface_Node_Configuration__c QuoteConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Quote Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'Quote Configuration',
                                                                                                                               
                                                                                                                             buildertek__Icon_URL__c = ICON_URL);
                                                                                                                               
                                                                                                                           
                                                                                                                                   
        adminConfigurationList.add(QuoteConfiguration);
        
           buildertek__Admin_Interface_Node_Configuration__c RFQConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'RFQ Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'RFQ Configuration',
                                                                                                                               
                                                                                                                             buildertek__Icon_URL__c = ICON_URL);
                                                                                                                               
                                                                                                                           
                                                                                                                                   
        adminConfigurationList.add(RFQConfiguration);
        
           buildertek__Admin_Interface_Node_Configuration__c SOVConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'SOV Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'SOV Configuration',
                                                                                                                               
                                                                                                                             buildertek__Icon_URL__c = ICON_URL);
                                                                                                                               
                                                                                                                           
                                                                                                                                   
        adminConfigurationList.add(SOVConfiguration);
        
            buildertek__Admin_Interface_Node_Configuration__c StripeSettings = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Stripe Settings',
                                                                                                                              buildertek__Tab_Name__c = 'Stripe Settings',
                                                                                                                                buildertek__Page_URL__c = '/apex/buildertek__BTStripeSettings',
                                                                                                                                        buildertek__Description__c = 'Configure Stripe Process for your organization.',
                                                                                                                                      buildertek__Index__c = 15,
                                                                                                                             buildertek__Icon_URL__c = ICON_URL);
                                                                                                                               
                                                                                                                           
                                                                                                                                   
        adminConfigurationList.add(StripeSettings);
        
          buildertek__Admin_Interface_Node_Configuration__c SystemConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'System Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'System Configuration',
                                                                                                                            
                                                                                                                                        buildertek__Description__c = 'Provide AWS Access Key Id, Secret Key and other values needed to configure application for your organization.',
                                                                                                                                      buildertek__Index__c = 1,
                                                                                                                             buildertek__Icon_URL__c = ICON_URL);
                                                                                                                               
                                                                                                                           
                                                                                                                                   
        adminConfigurationList.add(SystemConfiguration);
        
           buildertek__Admin_Interface_Node_Configuration__c TrainingSettings = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Training Settings',
                                                                                                                              buildertek__Tab_Name__c = 'Training Settings',
                                                                                                                                buildertek__Page_URL__c = '/apex/buildertek__TrainingSettings',
                                                                                                                                        buildertek__Description__c = 'Configure Training Process for your organization.',
                                                                                                                                      buildertek__Index__c = 16,
                                                                                                                             buildertek__Icon_URL__c = ICON_URL);
                                                                                                                               
                                                                                                                           
                                                                                                                                   
        adminConfigurationList.add(TrainingSettings);
        
          buildertek__Admin_Interface_Node_Configuration__c TurnoffCostOptionAllowanceCheck = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Turn off Cost Option Allowance Check',
                                                                                                                              buildertek__Tab_Name__c = 'Turn off Cost Option Allowance Check',
                                                                                                                              
                                                                                                                                     //   buildertek__Description__c = 'Configure Training Process for your organization.',
                                                                                                                                      buildertek__Index__c = 0,
                                                                                                                             buildertek__Icon_URL__c = ICON_URL);
                                                                                                                               
                                                                                                                           
                                                                                                                                   
        adminConfigurationList.add(TurnoffCostOptionAllowanceCheck);
        
        if(!adminConfigurationList.isEmpty()){
            Insert adminConfigurationList;
        }
        
        /*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
        
        buildertek__Admin_Interface_Node_Configuration__c childBOXSettings = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'BOX Settings',
                                                                                                                                   buildertek__Tab_Name__c = 'BOX Settings',
                                                                                                                                   buildertek__Icon_URL__c = ICON_URL,
                                                                                                                                   buildertek__Page_URL__c = '/apex/buildertek__BT_BOX_Settings',
                                                                                                                                   buildertek__Parent_Node__c = BOXSettings.Id);
        childAdminConfigurationList.add(childBOXSettings);
        
          buildertek__Admin_Interface_Node_Configuration__c childBudgetConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Budget Configurationss',
                                                                                                                                   buildertek__Tab_Name__c = 'Budget Configurations',
                                                                                                                                   buildertek__Icon_URL__c = ICON_URL,
                                                                                                                                   buildertek__Page_URL__c = '/apex/buildertek__BT_CreateBudgetConfiguration',
                                                                                                                                   buildertek__Parent_Node__c = BudgetConfiguration.Id);
        childAdminConfigurationList.add(childBudgetConfiguration);
        
         buildertek__Admin_Interface_Node_Configuration__c childChangeOrderConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Change Order Configuration',
                                                                                                                                   buildertek__Tab_Name__c = 'Change Order Configurations',
                                                                                                                                   buildertek__Icon_URL__c = ICON_URL,
                                                                                                                                   buildertek__Page_URL__c = '/apex/buildertek__BT_Change_Order_On_Overage',
                                                                                                                                   buildertek__Parent_Node__c = ChangeOrderConfiguration.Id);
        childAdminConfigurationList.add(childChangeOrderConfiguration);
        
          buildertek__Admin_Interface_Node_Configuration__c childCreateAccount = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Create Account',
                                                                                                                                   buildertek__Tab_Name__c = 'Create Account',
                                                                                                                                   buildertek__Icon_URL__c = ICON_URL,
                                                                                                                                    buildertek__Index__c = 13,
                                                                                                                                      buildertek__Description__c = 'Configure Accounts',
                                                                                                                                   buildertek__Page_URL__c = '/apex/buildertek__DisplayContents?id=a0H1K00000aWTm4UAG',
                                                                                                                                   buildertek__Parent_Node__c = CreatingAccountsandContacts.Id);
        childAdminConfigurationList.add(childCreateAccount);
        
           buildertek__Admin_Interface_Node_Configuration__c childCreateContact = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Create Contact',
                                                                                                                                   buildertek__Tab_Name__c = 'Create Contact',
                                                                                                                                   buildertek__Icon_URL__c = ICON_URL,
                                                                                                                                    buildertek__Index__c = 13,
                                                                                                                                      buildertek__Description__c = 'Configure Contacts',
                                                                                                                                   buildertek__Page_URL__c = '/apex/buildertek__DisplayContents?id=a0H1K00000aWTm9UAG',
                                                                                                                                   buildertek__Parent_Node__c = CreatingAccountsandContacts.Id);
        childAdminConfigurationList.add(childCreateContact);
        
          buildertek__Admin_Interface_Node_Configuration__c childCreateContractonQuoteAcceptance = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Create Contract on Quote Acceptance',
                                                                                                                                   buildertek__Tab_Name__c = 'Create Contract on Quote Acceptance',
                                                                                                                                   buildertek__Icon_URL__c = ICON_URL,
                                                                                                                                  //  buildertek__Index__c = 13,
                                                                                                                                  //    buildertek__Description__c = 'Configure Contacts',
                                                                                                                                   buildertek__Page_URL__c = '/apex/buildertek__BT_CreateContractOnQuoteAcceptance',
                                                                                                                                   buildertek__Parent_Node__c = BTContractConfiguration.Id);
        childAdminConfigurationList.add(childCreateContractonQuoteAcceptance);
        
          buildertek__Admin_Interface_Node_Configuration__c childCreatinganewUser = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Creating a new User',
                                                                                                                              buildertek__Tab_Name__c = 'Creating a new User',
                                                                                                                            //   buildertek__Index__c = 13,
                                                                                                                                   buildertek__Description__c = 'Configure creating new users',
                                                                                                                              buildertek__Icon_URL__c = ICON_URL,
                                                                                                                                 buildertek__Page_URL__c = '/apex/buildertek__DisplayContents?id=a0H1K00000aWTfhUAG',
                                                                                                                                   buildertek__Parent_Node__c = BTTraining.Id);
        childAdminConfigurationList.add(childCreatinganewUser);
        
          buildertek__Admin_Interface_Node_Configuration__c childCreatingAccountsandContacts = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Creating Accounts and Contacts',
                                                                                                                              buildertek__Tab_Name__c = 'Creating Accounts and Contacts',
                                                                                                                               buildertek__Index__c = 13,
                                                                                                                                   buildertek__Description__c = 'Configure Accounts and Contacts',
                                                                                                                              buildertek__Icon_URL__c = ICON_URL,
                                                                                                                             buildertek__Parent_Node__c = BTTraining.Id);
        childAdminConfigurationList.add(childCreatingAccountsandContacts);
        
            buildertek__Admin_Interface_Node_Configuration__c childFileExplorerPageConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'File Explorer Page Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'File Explorer Page Configuration',
                                                                                                                               buildertek__Index__c = 2,
                                                                                                                              buildertek__Description__c = 'Configure File Explorer Interface for your organization.',
                                                                                                                              buildertek__Icon_URL__c = ICON_URL,
                                                                                                                                buildertek__Page_URL__c = '/apex/buildertek__BT_FileExplorerPageConfiguration',
                                                                                                                                buildertek__Parent_Node__c = BTDocumentConfiguration.Id);
                                                                                                                                
        
         childAdminConfigurationList.add(childFileExplorerPageConfiguration);
        
          buildertek__Admin_Interface_Node_Configuration__c childFileUploadPageConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'File Upload Page Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'File Upload Page Configuration',
                                                                                                                               buildertek__Index__c = 3,
                                                                                                                              buildertek__Description__c = 'Configure default values for new file.',
                                                                                                                              buildertek__Icon_URL__c = ICON_URL,
                                                                                                                               buildertek__Page_URL__c = '/apex/buildertek__BT_FileUploadPageConfiguration',
                                                                                                                                buildertek__Parent_Node__c = BTDocumentConfiguration.Id);
                                                                                                                                   
          childAdminConfigurationList.add(childFileUploadPageConfiguration);
        
          buildertek__Admin_Interface_Node_Configuration__c childMSA1Configuration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'MSA Configurationn',
                                                                                                                              buildertek__Tab_Name__c = 'MSA Configurationn',
                                                                                                                             buildertek__Icon_URL__c = ICON_URL,
                                                                                                                              buildertek__Page_URL__c = '/apex/buildertek__BT_MSA_Settings',
                                                                                                                                buildertek__Parent_Node__c = MSAConfiguration.Id);
        
           childAdminConfigurationList.add(childMSA1Configuration);
        
           buildertek__Admin_Interface_Node_Configuration__c childOpportunityConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Opportunity Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'Opportunity Configuration',
                                                                                                                             buildertek__Icon_URL__c = ICON_URL,
                                                                                                                                buildertek__Page_URL__c = '/apex/buildertek__BT_CreateOpportunityConfiguration',
                                                                                                                                buildertek__Parent_Node__c = BTOpportunityConfiguration.Id);
              childAdminConfigurationList.add(childOpportunityConfiguration);
        
         buildertek__Admin_Interface_Node_Configuration__c childPaymentApplicationConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Payment Application Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'Payment Application Configuration',
                                                                                                                             buildertek__Icon_URL__c = ICON_URL,
                                                                                                                              buildertek__Page_URL__c = '/apex/buildertek__BT_CreatePaymentApplicationConfiguration',
                                                                                                                                buildertek__Parent_Node__c = BTPaymentApplicationConfiguration.Id);
                                                                                                                               
        
           childAdminConfigurationList.add(childPaymentApplicationConfiguration);
        
          buildertek__Admin_Interface_Node_Configuration__c childPreQualificationConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Pre Qualification Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'Pre Qualification Configuration',
                                                                                                                             buildertek__Icon_URL__c = ICON_URL,
                                                                                                                               buildertek__Page_URL__c = '/apex/buildertek__BT_PreQualificationConfiguration',
                                                                                                                                buildertek__Parent_Node__c = BTPreQualificationConfiguration.Id);
        
        childAdminConfigurationList.add(childPreQualificationConfiguration);
        
           buildertek__Admin_Interface_Node_Configuration__c childProjectConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Project Configurationn',
                                                                                                                              buildertek__Tab_Name__c = 'Project Configuration',
                                                                                                                             buildertek__Icon_URL__c = ICON_URL,
                                                                                                                              buildertek__Page_URL__c = '/apex/buildertek__BT_CreateProjectConfiguration',
                                                                                                                                buildertek__Parent_Node__c = BTProjectConfiguration.Id);
                                                                                                                               
        
         childAdminConfigurationList.add(childProjectConfiguration);
        
         buildertek__Admin_Interface_Node_Configuration__c childPurchaseOrderConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Purchase Order Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'Purchase Order Configuration',
                                                                                                                                buildertek__Description__c = 'Use to send email on PO Approved.',
                                                                                                                             buildertek__Icon_URL__c = ICON_URL,
                                                                                                                                buildertek__Page_URL__c = '/apex/buildertek__BT_CreatePurchaseOrderConfiguration',
                                                                                                                                buildertek__Parent_Node__c = BTPurchaseOrderConfiguration.Id);
          
                 childAdminConfigurationList.add(childPurchaseOrderConfiguration);
        
           buildertek__Admin_Interface_Node_Configuration__c childQuoteConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Quote Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'Quote Configuration',
                                                                                                                                buildertek__Page_URL__c = '/apex/buildertek__CreateProjectfromQuoteAcceptanceonOpp',
                                                                                                                                buildertek__Parent_Node__c = BTQuoteConfiguration.Id,
                                                                                                                             buildertek__Icon_URL__c = ICON_URL);
        
           childAdminConfigurationList.add(childQuoteConfiguration);
        
          buildertek__Admin_Interface_Node_Configuration__c childRFQConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'RFQ Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'RFQ Configuration',
                                                                                                                                 buildertek__Page_URL__c = '/apex/buildertek__BT_CreateRFQConfiguration',
                                                                                                                                buildertek__Parent_Node__c = BTRFQConfiguration.Id, 
                                                                                                                             buildertek__Icon_URL__c = ICON_URL);
        
         childAdminConfigurationList.add(childRFQConfiguration);
        
           buildertek__Admin_Interface_Node_Configuration__c childSOVConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'SOV Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'SOV Configuration',
                                                                                                                               buildertek__Page_URL__c = '/apex/buildertek__BT_CreateSOVConfiguration',
                                                                                                                                buildertek__Parent_Node__c = BTSOVConfiguration.Id,  
                                                                                                                             buildertek__Icon_URL__c = ICON_URL);
        
        childAdminConfigurationList.add(childSOVConfiguration);
        
         buildertek__Admin_Interface_Node_Configuration__c childSystemConfiguration = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'System Configuration',
                                                                                                                              buildertek__Tab_Name__c = 'System Configuration',
                                                                                                                             buildertek__Page_URL__c = '/apex/buildertek__BT_ApplicationConfiguration',
                                                                                                                                buildertek__Parent_Node__c = BTDocumentConfiguration.Id, 
                                                                                                                                        buildertek__Description__c = 'Provide AWS Access Key Id, Secret Key and other values needed to configure application for your organization.',
                                                                                                                                      buildertek__Index__c = 1,
                                                                                                                             buildertek__Icon_URL__c = ICON_URL);
        
          childAdminConfigurationList.add(childSystemConfiguration);
        
          buildertek__Admin_Interface_Node_Configuration__c childTurnoffCostOptionAllowanceCheck = New buildertek__Admin_Interface_Node_Configuration__c(Name = 'Turn off Cost Option Allowance Check',
                                                                                                                              buildertek__Tab_Name__c = 'Turn off Cost Option Allowance Check',
                                                                                                                                buildertek__Page_URL__c = '/apex/buildertek__BT_CostOverageCheck',
                                                                                                                                buildertek__Parent_Node__c = BTChangeOrderConfiguration.Id, 
                                                                                                                                     //   buildertek__Description__c = 'Configure Training Process for your organization.',
                                                                                                                                      buildertek__Index__c = 0,
                                                                                                                             buildertek__Icon_URL__c = ICON_URL);
                                                                                                                               
                                                                                                                           
                                                                                                                                   
      childAdminConfigurationList.add(childTurnoffCostOptionAllowanceCheck);
        
        if(!childAdminConfigurationList.isEmpty()){
            Insert childAdminConfigurationList;
        }
        
    }

}