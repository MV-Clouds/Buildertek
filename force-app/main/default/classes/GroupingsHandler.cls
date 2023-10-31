public without sharing class GroupingsHandler {

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public GroupingsHandler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void afterInsert(List<BT_Grouping__c> newGroupings, Map<Id, BT_Grouping__c> newGroupingsMap) {

        List<buildertek__Budget_Line_Group__c> BudgetLineGroups = [SELECT Id, Name, buildertek__Description__c, buildertek__Sorting_Id__c FROM buildertek__Budget_Line_Group__c ];
        List<buildertek__Quote_Line_Group__c> QuoteLineGroups = [SELECT Id, Name, buildertek__Description__c, buildertek__Sort_Id__c FROM buildertek__Quote_Line_Group__c ];

        List<buildertek__Budget_Line_Group__c> BudgetLineGroupsToInsert = new List<buildertek__Budget_Line_Group__c>();
        List<buildertek__Quote_Line_Group__c> QuoteLineGroupsToInsert = new List<buildertek__Quote_Line_Group__c>();

        List<buildertek__Budget_Line_Group__c> BudgetLineGroupsToUpdate = new List<buildertek__Budget_Line_Group__c>();
        List<buildertek__Quote_Line_Group__c> QuoteLineGroupsToUpdate = new List<buildertek__Quote_Line_Group__c>();

        boolean BudgetGroupingexists = false;
        boolean QuoteGroupingexists = false;

        for (BT_Grouping__c newGrouping : newGroupings) {
            for (buildertek__Budget_Line_Group__c BudgetLineGroup : BudgetLineGroups) {
                if (BudgetLineGroup.Name == newGrouping.Name) {
                    BudgetGroupingexists = true;
                    BudgetLineGroup.buildertek__Description__c = newGrouping.buildertek__Description__c;
                    BudgetLineGroup.buildertek__Sorting_Id__c = newGrouping.buildertek__Sort_Id__c;
                    BudgetLineGroupsToUpdate.add(BudgetLineGroup);
                }
            }
            if (!BudgetGroupingexists) {
                buildertek__Budget_Line_Group__c BudgetLineGroup = new buildertek__Budget_Line_Group__c();
                BudgetLineGroup.Name = newGrouping.Name;
                BudgetLineGroup.buildertek__Description__c = newGrouping.buildertek__Description__c;
                BudgetLineGroup.buildertek__Sorting_Id__c = newGrouping.buildertek__Sort_Id__c;
                BudgetLineGroupsToInsert.add(BudgetLineGroup);
            }
            BudgetGroupingexists = false;

            for (buildertek__Quote_Line_Group__c QuoteLineGroup : QuoteLineGroups) {
                if (QuoteLineGroup.Name == newGrouping.Name) {
                    QuoteGroupingexists = true;
                    QuoteLineGroup.buildertek__Description__c = newGrouping.buildertek__Description__c;
                    // QuoteLineGroup.buildertek__Sort_Id__c = newGrouping.buildertek__Sort_Id__c;
                    QuoteLineGroupsToUpdate.add(QuoteLineGroup);
                }
            }
            if (!QuoteGroupingexists) {
                buildertek__Quote_Line_Group__c QuoteLineGroup = new buildertek__Quote_Line_Group__c();
                QuoteLineGroup.Name = newGrouping.Name;
                QuoteLineGroup.buildertek__Description__c = newGrouping.buildertek__Description__c;
                // QuoteLineGroup.buildertek__Sort_Id__c = newGrouping.buildertek__Sort_Id__c;
                QuoteLineGroupsToInsert.add(QuoteLineGroup);
            }
        }

        if (BudgetLineGroupsToInsert.size() > 0) {
            insert BudgetLineGroupsToInsert;
        }

        if (BudgetLineGroupsToUpdate.size() > 0) {
            update BudgetLineGroupsToUpdate;
        }

        if (QuoteLineGroupsToInsert.size() > 0) {
            insert QuoteLineGroupsToInsert;
        }

        if (QuoteLineGroupsToUpdate.size() > 0) {
            update QuoteLineGroupsToUpdate;
        }
    }

    public void afterUpdate(List<BT_Grouping__c> newGroupings, Map<Id, BT_Grouping__c> newGroupingsMap, List<BT_Grouping__c> oldGroupings, Map<Id, BT_Grouping__c> oldGroupingsMap) {

        List<buildertek__Budget_Line_Group__c> BudgetLineGroups = [SELECT Id, Name, buildertek__Description__c, buildertek__Sorting_Id__c FROM buildertek__Budget_Line_Group__c ];
        List<buildertek__Quote_Line_Group__c> QuoteLineGroups = [SELECT Id, Name, buildertek__Description__c, buildertek__Sort_Id__c FROM buildertek__Quote_Line_Group__c ];

        List<buildertek__Budget_Line_Group__c> BudgetLineGroupsToUpdate = new List<buildertek__Budget_Line_Group__c>();
        List<buildertek__Quote_Line_Group__c> QuoteLineGroupsToUpdate = new List<buildertek__Quote_Line_Group__c>();

        List<buildertek__Budget_Line_Group__c> BudgetLineGroupstoDelete = new List<buildertek__Budget_Line_Group__c>();
        List<buildertek__Quote_Line_Group__c> QuoteLineGroupstoDelete = new List<buildertek__Quote_Line_Group__c>();

        Boolean NameExists = false;

        //itertate over new groupings
        for(BT_Grouping__c newGrouping : newGroupings) {
            //iterate over old groupings
            for(BT_Grouping__c oldGrouping : oldGroupings) {
                //if the new grouping name is the same as the old grouping name
                if(newGrouping.Name == oldGroupingsMap.get(newGrouping.Id).Name) {
                    NameExists = true;
                    //iterate over budget line groups
                    for(buildertek__Budget_Line_Group__c BudgetLineGroup : BudgetLineGroups) {
                        //if the budget line group name is the same as the new grouping name
                        if(BudgetLineGroup.Name == newGrouping.Name) {
                            //update the budget line group
                            BudgetLineGroup.buildertek__Description__c = newGrouping.buildertek__Description__c;
                            BudgetLineGroup.buildertek__Sorting_Id__c = newGrouping.buildertek__Sort_Id__c;
                            BudgetLineGroupsToUpdate.add(BudgetLineGroup);
                        }
                    }
                    //iterate over quote line groups
                    for(buildertek__Quote_Line_Group__c QuoteLineGroup : QuoteLineGroups) {
                        //if the quote line group name is the same as the new grouping name
                        if(QuoteLineGroup.Name == newGrouping.Name) {
                            //update the quote line group
                            QuoteLineGroup.buildertek__Description__c = newGrouping.buildertek__Description__c;
                            // QuoteLineGroup.buildertek__Sort_Id__c = newGrouping.buildertek__Sort_Id__c;
                            QuoteLineGroupsToUpdate.add(QuoteLineGroup);
                        }
                    }
                }
            }
            if(!NameExists){
                BT_Grouping__c oldGrouping = oldGroupingsMap.get(newGrouping.Id);

                //iterate over budget line groups
                for(buildertek__Budget_Line_Group__c BudgetLineGroup : BudgetLineGroups) {
                    //if the budget line group name is the same as the new grouping name
                    if(BudgetLineGroup.Name == oldGrouping.Name) {
                        Boolean BudgetNameExists = false;
                        for(buildertek__Budget_Line_Group__c BudgetLineGroup2 : BudgetLineGroups) {
                            if(BudgetLineGroup2.Name == newGrouping.Name) {
                                BudgetNameExists = true;
                                BudgetLineGroup2.Name = newGrouping.Name;
                                BudgetLineGroup2.buildertek__Description__c = newGrouping.buildertek__Description__c;
                                BudgetLineGroup2.buildertek__Sorting_Id__c = newGrouping.buildertek__Sort_Id__c;
                                BudgetLineGroupsToUpdate.add(BudgetLineGroup2);
                                // BudgetLineGroupstoDelete.add(BudgetLineGroup);
                            }
                        }
                        if(!BudgetNameExists) {
                            BudgetLineGroup.Name = newGrouping.Name;
                            BudgetLineGroup.buildertek__Description__c = newGrouping.buildertek__Description__c;
                            BudgetLineGroup.buildertek__Sorting_Id__c = newGrouping.buildertek__Sort_Id__c;
                            BudgetLineGroupsToUpdate.add(BudgetLineGroup);
                        }
                    }
                }

                //iterate over quote line groups
                for(buildertek__Quote_Line_Group__c QuoteLineGroup : QuoteLineGroups) {
                    //if the quote line group name is the same as the new grouping name
                    if(QuoteLineGroup.Name == oldGrouping.Name) {
                        Boolean QuoteNameExists = false;
                        for(buildertek__Quote_Line_Group__c QuoteLineGroup2 : QuoteLineGroups) {
                            if(QuoteLineGroup2.Name == newGrouping.Name) {
                                QuoteNameExists = true;
                                QuoteLineGroup2.Name = newGrouping.Name;
                                QuoteLineGroup2.buildertek__Description__c = newGrouping.buildertek__Description__c;
                                // QuoteLineGroup2.buildertek__Sort_Id__c = newGrouping.buildertek__Sort_Id__c;
                                QuoteLineGroupsToUpdate.add(QuoteLineGroup2);
                                // QuoteLineGroupstoDelete.add(QuoteLineGroup);
                            }
                        }
                        if(!QuoteNameExists) {
                            QuoteLineGroup.Name = newGrouping.Name;
                            QuoteLineGroup.buildertek__Description__c = newGrouping.buildertek__Description__c;
                            // QuoteLineGroup.buildertek__Sort_Id__c = newGrouping.buildertek__Sort_Id__c;
                            QuoteLineGroupsToUpdate.add(QuoteLineGroup);
                        }
                    }
                }
                

            }
        }

        if (BudgetLineGroupsToUpdate.size() > 0) {
            update BudgetLineGroupsToUpdate;
        }

        if (QuoteLineGroupsToUpdate.size() > 0) {
            update QuoteLineGroupsToUpdate;
        }

        if (BudgetLineGroupstoDelete.size() > 0) {
            delete BudgetLineGroupstoDelete;
        }

        if (QuoteLineGroupstoDelete.size() > 0) {
            delete QuoteLineGroupstoDelete;
        }
    }

    public void beforeDelete(List<BT_Grouping__c> oldGroupings, Map<Id, BT_Grouping__c> oldGroupingsMap) {

        System.debug('Before Delete ');

        List<buildertek__Budget_Line_Group__c> BudgetLineGroups = [SELECT Id, Name, buildertek__Description__c, buildertek__Sorting_Id__c FROM buildertek__Budget_Line_Group__c ];
        List<buildertek__Quote_Line_Group__c> QuoteLineGroups = [SELECT Id, Name, buildertek__Description__c, buildertek__Sort_Id__c FROM buildertek__Quote_Line_Group__c ];

        List<buildertek__Budget_Line_Group__c> BudgetLineGroupstoDelete = new List<buildertek__Budget_Line_Group__c>();
        List<buildertek__Quote_Line_Group__c> QuoteLineGroupstoDelete = new List<buildertek__Quote_Line_Group__c>();

        for (BT_Grouping__c oldGrouping : oldGroupings) {
            for (buildertek__Budget_Line_Group__c BudgetLineGroup : BudgetLineGroups) {
                if (BudgetLineGroup.Name == oldGrouping.Name) {
                    System.debug('BudgetLineGroup ' + BudgetLineGroup);
                    BudgetLineGroupstoDelete.add(BudgetLineGroup);
                }
            }
            for (buildertek__Quote_Line_Group__c QuoteLineGroup : QuoteLineGroups) {
                if (QuoteLineGroup.Name == oldGrouping.Name) {
                    System.debug('QuoteLineGroup ' + QuoteLineGroup);
                    QuoteLineGroupstoDelete.add(QuoteLineGroup);
                }
            }
        }

        if (BudgetLineGroupstoDelete.size() > 0) {
            delete BudgetLineGroupstoDelete;
        }

        if (QuoteLineGroupstoDelete.size() > 0) {
            delete QuoteLineGroupstoDelete;
        }

        System.debug('Before Delete End');

    }

}