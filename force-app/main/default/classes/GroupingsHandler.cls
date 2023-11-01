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
        List<buildertek__Contract_Line_Group__c> ContractLineGroups = [SELECT Id, Name, buildertek__Description__c, buildertek__Sort_Id__c FROM buildertek__Contract_Line_Group__c ];
        List<buildertek__Build_Phase__c> BuildPhases = [SELECT Id, Name FROM buildertek__Build_Phase__c ];

        List<buildertek__Budget_Line_Group__c> BudgetLineGroupsToInsert = new List<buildertek__Budget_Line_Group__c>();
        List<buildertek__Quote_Line_Group__c> QuoteLineGroupsToInsert = new List<buildertek__Quote_Line_Group__c>();
        List<buildertek__Contract_Line_Group__c> ContractLineGroupsToInsert = new List<buildertek__Contract_Line_Group__c>();
        List<buildertek__Build_Phase__c> BuildPhasesToInsert = new List<buildertek__Build_Phase__c>();

        List<buildertek__Budget_Line_Group__c> BudgetLineGroupsToUpdate = new List<buildertek__Budget_Line_Group__c>();
        List<buildertek__Quote_Line_Group__c> QuoteLineGroupsToUpdate = new List<buildertek__Quote_Line_Group__c>();
        List<buildertek__Contract_Line_Group__c> ContractLineGroupsToUpdate = new List<buildertek__Contract_Line_Group__c>();
        List<buildertek__Build_Phase__c> BuildPhasesToUpdate = new List<buildertek__Build_Phase__c>();

        boolean BudgetGroupingexists = false;
        boolean QuoteGroupingexists = false;
        boolean ContractGroupingexists = false;
        boolean BuildPhaseexists = false;

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
            QuoteGroupingexists = false;

            for (buildertek__Contract_Line_Group__c ContractLineGroup : ContractLineGroups) {
                if (ContractLineGroup.Name == newGrouping.Name) {
                    ContractGroupingexists = true;
                    ContractLineGroup.buildertek__Description__c = newGrouping.buildertek__Description__c;
                    // ContractLineGroup.buildertek__Sort_Id__c = newGrouping.buildertek__Sort_Id__c;
                    ContractLineGroupsToUpdate.add(ContractLineGroup);
                }
            }
            if (!ContractGroupingexists) {
                buildertek__Contract_Line_Group__c ContractLineGroup = new buildertek__Contract_Line_Group__c();
                ContractLineGroup.Name = newGrouping.Name;
                ContractLineGroup.buildertek__Description__c = newGrouping.buildertek__Description__c;
                // ContractLineGroup.buildertek__Sort_Id__c = newGrouping.buildertek__Sort_Id__c;
                ContractLineGroupsToInsert.add(ContractLineGroup);
            }
            ContractGroupingexists = false;

            for (buildertek__Build_Phase__c BuildPhase : BuildPhases) {
                if (BuildPhase.Name == newGrouping.Name) {
                    BuildPhaseexists = true;
                    //code should be written over here if Build Phase inculdes any other field
                    //contractLineGroup.buildertek__Description__c = newGrouping.buildertek__Description__c;
                    // BuildPhasesToUpdate.add(BuildPhase);
                }
            }
            if (!BuildPhaseexists) {
                buildertek__Build_Phase__c BuildPhase = new buildertek__Build_Phase__c();
                BuildPhase.Name = newGrouping.Name;
                // BuildPhase.buildertek__Description__c = newGrouping.buildertek__Description__c;
                BuildPhasesToInsert.add(BuildPhase);
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

        if (ContractLineGroupsToInsert.size() > 0) {
            insert ContractLineGroupsToInsert;
        }

        if (ContractLineGroupsToUpdate.size() > 0) {
            update ContractLineGroupsToUpdate;
        }

        if (BuildPhasesToInsert.size() > 0) {
            insert BuildPhasesToInsert;
        }

        if (BuildPhasesToUpdate.size() > 0) {
            update BuildPhasesToUpdate;
        }

    }

    public void afterUpdate(List<BT_Grouping__c> newGroupings, Map<Id, BT_Grouping__c> newGroupingsMap, List<BT_Grouping__c> oldGroupings, Map<Id, BT_Grouping__c> oldGroupingsMap) {

        List<buildertek__Budget_Line_Group__c> BudgetLineGroups = [SELECT Id, Name, buildertek__Description__c, buildertek__Sorting_Id__c FROM buildertek__Budget_Line_Group__c ];
        List<buildertek__Quote_Line_Group__c> QuoteLineGroups = [SELECT Id, Name, buildertek__Description__c, buildertek__Sort_Id__c FROM buildertek__Quote_Line_Group__c ];
        List<buildertek__Contract_Line_Group__c> ContractLineGroups = [SELECT Id, Name, buildertek__Description__c, buildertek__Sort_Id__c FROM buildertek__Contract_Line_Group__c ];
        List<buildertek__Build_Phase__c> BuildPhases = [SELECT Id, Name FROM buildertek__Build_Phase__c ];

        List<buildertek__Budget_Line_Group__c> BudgetLineGroupsToUpdate = new List<buildertek__Budget_Line_Group__c>();
        List<buildertek__Quote_Line_Group__c> QuoteLineGroupsToUpdate = new List<buildertek__Quote_Line_Group__c>();
        List<buildertek__Contract_Line_Group__c> ContractLineGroupsToUpdate = new List<buildertek__Contract_Line_Group__c>();
        List<buildertek__Build_Phase__c> BuildPhasesToUpdate = new List<buildertek__Build_Phase__c>();

        List<buildertek__Budget_Line_Group__c> BudgetLineGroupstoDelete = new List<buildertek__Budget_Line_Group__c>();
        List<buildertek__Quote_Line_Group__c> QuoteLineGroupstoDelete = new List<buildertek__Quote_Line_Group__c>();
        List<buildertek__Contract_Line_Group__c> ContractLineGroupstoDelete = new List<buildertek__Contract_Line_Group__c>();
        List<buildertek__Build_Phase__c> BuildPhasestoDelete = new List<buildertek__Build_Phase__c>();

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

                    //iterate over contract line groups
                    for(buildertek__Contract_Line_Group__c ContractLineGroup : ContractLineGroups) {
                        //if the contract line group name is the same as the new grouping name
                        if(ContractLineGroup.Name == newGrouping.Name) {
                            //update the contract line group
                            ContractLineGroup.buildertek__Description__c = newGrouping.buildertek__Description__c;
                            // ContractLineGroup.buildertek__Sort_Id__c = newGrouping.buildertek__Sort_Id__c;
                            ContractLineGroupsToUpdate.add(ContractLineGroup);
                        }
                    }

                    //iterate over build phases
                    for(buildertek__Build_Phase__c BuildPhase : BuildPhases) {
                        //if the build phase name is the same as the new grouping name
                        if(BuildPhase.Name == newGrouping.Name) {
                            //update the build phase
                            // BuildPhase.buildertek__Description__c = newGrouping.buildertek__Description__c;
                            // BuildPhasesToUpdate.add(BuildPhase);
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

                //iterate over contract line groups
                for(buildertek__Contract_Line_Group__c ContractLineGroup : ContractLineGroups) {
                    //if the contract line group name is the same as the new grouping name
                    if(ContractLineGroup.Name == oldGrouping.Name) {
                        Boolean ContractNameExists = false;
                        for(buildertek__Contract_Line_Group__c ContractLineGroup2 : ContractLineGroups) {
                            if(ContractLineGroup2.Name == newGrouping.Name) {
                                ContractNameExists = true;
                                ContractLineGroup2.Name = newGrouping.Name;
                                ContractLineGroup2.buildertek__Description__c = newGrouping.buildertek__Description__c;
                                // ContractLineGroup2.buildertek__Sort_Id__c = newGrouping.buildertek__Sort_Id__c;
                                ContractLineGroupsToUpdate.add(ContractLineGroup2);
                                // ContractLineGroupstoDelete.add(ContractLineGroup);
                            }
                        }
                        if(!ContractNameExists) {
                            ContractLineGroup.Name = newGrouping.Name;
                            ContractLineGroup.buildertek__Description__c = newGrouping.buildertek__Description__c;
                            // ContractLineGroup.buildertek__Sort_Id__c = newGrouping.buildertek__Sort_Id__c;
                            ContractLineGroupsToUpdate.add(ContractLineGroup);
                        }
                    }
                }

                //iterate over build phases
                for(buildertek__Build_Phase__c BuildPhase : BuildPhases) {
                    //if the build phase name is the same as the new grouping name
                    if(BuildPhase.Name == oldGrouping.Name) {
                        Boolean BuildNameExists = false;
                        for(buildertek__Build_Phase__c BuildPhase2 : BuildPhases) {
                            if(BuildPhase2.Name == newGrouping.Name) {
                                BuildNameExists = true;
                                BuildPhase2.Name = newGrouping.Name;
                                // BuildPhase2.buildertek__Description__c = newGrouping.buildertek__Description__c;
                                BuildPhasesToUpdate.add(BuildPhase2);
                                // BuildPhasestoDelete.add(BuildPhase);
                            }
                        }
                        if(!BuildNameExists) {
                            BuildPhase.Name = newGrouping.Name;
                            // BuildPhase.buildertek__Description__c = newGrouping.buildertek__Description__c;
                            BuildPhasesToUpdate.add(BuildPhase);
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

        if (ContractLineGroupsToUpdate.size() > 0) {
            update ContractLineGroupsToUpdate;
        }

        if (ContractLineGroupstoDelete.size() > 0) {
            delete ContractLineGroupstoDelete;
        }

        if (BuildPhasesToUpdate.size() > 0) {
            update BuildPhasesToUpdate;
        }

        if (BuildPhasestoDelete.size() > 0) {
            delete BuildPhasestoDelete;
        }
    }

    public void beforeDelete(List<BT_Grouping__c> oldGroupings, Map<Id, BT_Grouping__c> oldGroupingsMap) {

        System.debug('Before Delete ');

        List<buildertek__Budget_Line_Group__c> BudgetLineGroups = [SELECT Id, Name, buildertek__Description__c, buildertek__Sorting_Id__c FROM buildertek__Budget_Line_Group__c ];
        List<buildertek__Quote_Line_Group__c> QuoteLineGroups = [SELECT Id, Name, buildertek__Description__c, buildertek__Sort_Id__c FROM buildertek__Quote_Line_Group__c ];
        List<buildertek__Contract_Line_Group__c> ContractLineGroups = [SELECT Id, Name, buildertek__Description__c, buildertek__Sort_Id__c FROM buildertek__Contract_Line_Group__c ];
        List<buildertek__Build_Phase__c> BuildPhases = [SELECT Id, Name FROM buildertek__Build_Phase__c ];

        List<buildertek__Budget_Line_Group__c> BudgetLineGroupstoDelete = new List<buildertek__Budget_Line_Group__c>();
        List<buildertek__Quote_Line_Group__c> QuoteLineGroupstoDelete = new List<buildertek__Quote_Line_Group__c>();
        List <buildertek__Contract_Line_Group__c> ContractLineGroupstoDelete = new List<buildertek__Contract_Line_Group__c>();
        List<buildertek__Build_Phase__c> BuildPhasestoDelete = new List<buildertek__Build_Phase__c>();

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
            for (buildertek__Contract_Line_Group__c ContractLineGroup : ContractLineGroups) {
                if (ContractLineGroup.Name == oldGrouping.Name) {
                    System.debug('ContractLineGroup ' + ContractLineGroup);
                    ContractLineGroupstoDelete.add(ContractLineGroup);
                }
            }
            for (buildertek__Build_Phase__c BuildPhase : BuildPhases) {
                if (BuildPhase.Name == oldGrouping.Name) {
                    System.debug('BuildPhase ' + BuildPhase);
                    BuildPhasestoDelete.add(BuildPhase);
                }
            }

        }

        if (BudgetLineGroupstoDelete.size() > 0) {
            delete BudgetLineGroupstoDelete;
        }

        if (QuoteLineGroupstoDelete.size() > 0) {
            delete QuoteLineGroupstoDelete;
        }

        if (ContractLineGroupstoDelete.size() > 0) {
            delete ContractLineGroupstoDelete;
        }

        if (BuildPhasestoDelete.size() > 0) {
            delete BuildPhasestoDelete;
        }

        System.debug('Before Delete End');

    }

}