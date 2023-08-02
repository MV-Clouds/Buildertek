/* BT Lightning Component Helper.
 * Copyright 2017-2018, BuilderTek
 * All rights reserved
 *
 * Created by 
 *
 * - Modifications:
 */

/* Lightning CLI rule */
/*global JQ$ sforce*/
/* eslint-disable no-console, no-alert */
({

	deleteSelectedRecord: function (component, event, helper, objectName, recordIds){
		var action;
		action = component.get("c.deleteRecords");
        action.setParams({
            objectName: objectName,
            selectedRecords: recordIds
        });
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
            	var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
	                "title": "",
	                "message": "Data were succesfully deleted.",
	                "type": "success"
	            });
	            toastEvent.fire();
	            component.refreshData();
            }
        });
        
        $A.enqueueAction(action);
	},
	
	//initializeGrid: it will call from Component Js
    getGidDataRecords: function (component, event, helper, objectName, filterConditions, globalId, fieldSetName, groupingColumns, editableColumns, actions, callback) {
		var recordData, columnHeaders, columnModels, actionsessionId, actionGetColumnHeaders, actionGetColumnModels, actionRecordData, state;

        //Prepare actoin to retrive column header Json
        actionGetColumnHeaders = component.get("c.columnsHeader");
        actionGetColumnHeaders.setParams({
            objectName: objectName,
            fieldSetAPI: fieldSetName,
            groupingFields: groupingColumns,
            rowActions: actions
        });
        actionGetColumnHeaders.setStorable({
				ignoreExisting: true
			});
        
        actionGetColumnHeaders.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                component.set("v.ColumnHeaders", response.getReturnValue());
            }
        });
        
        
        //Prepare actoin to retrive column model Json
        actionGetColumnModels = component.get("c.columnsModels");
        actionGetColumnModels.setParams({
            objectName: objectName,
            fieldSetAPI: fieldSetName,
            groupingFields: groupingColumns,
            editableColumnList: editableColumns,
            rowActions: actions
        });
        actionGetColumnModels.setStorable({
				ignoreExisting: true
			});
			
        actionGetColumnModels.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                component.set("v.ColumnModels", response.getReturnValue());
            }
        });
        
        //Prepare actoin to retrive data Json
        actionRecordData = component.get("c.recordData");
        actionRecordData.setParams({
            objectName: objectName,
            filterConditions: filterConditions,
            fieldSetAPI: fieldSetName,
            parentId: component.get("v.parentId"),
            gridType: component.get("v.gridType")
        });
        actionRecordData.setStorable({
				ignoreExisting: true
			});
        
        actionRecordData.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
            	if(response.getReturnValue() != [] && response.getReturnValue() != '[]'){
            		component.set("v.RecordDetails", response.getReturnValue());
                } else {
                	component.set("v.RecordDetails", JSON.stringify(new Object()));
                }
                callback();
            }
        });
        
        actionsessionId = component.get("c.sessionId");
        actionsessionId.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                component.set("v.sessionId", response.getReturnValue());
            }
        });
        
        //enqueue GetColumnHeaders method
        $A.enqueueAction(actionGetColumnHeaders);

        //enqueue GetColumnModels method
        $A.enqueueAction(actionGetColumnModels);
        
        //enqueue RecordData method
        if(component.get("v.loadData")){
        	$A.enqueueAction(actionRecordData);
        }
        
        $A.enqueueAction(actionsessionId);
	},
	
    // Create grid for grid table and pager
    createGrid: function (component, event, helper) {
        // Getting table id, pager id and grouping flag
        var tableId, pagerId, grouping, gridDiv, groupingDiv, widgetDiv, groupingOl, groupingli, table, pager;
        tableId = component.get("v.TableId");
        pagerId = component.get("v.PagerId");
        grouping = component.get("v.Grouping");

        // Updating grid div id to avoid id duplication
        gridDiv = document.getElementById('gridDiv_' + tableId);
        if (gridDiv === null || gridDiv === undefined) {
            gridDiv = document.getElementById('gridDiv_' + tableId);
        }

        if (gridDiv !== undefined && gridDiv.id.indexOf(tableId) === -1) {
            gridDiv.setAttribute('id', 'gridDiv_' + tableId);
        }

        if (gridDiv !== undefined && gridDiv.innerHTML !== '') {
            return;
        }

        // Adding droppable section to drag the column headers for grouping
        if (grouping) {
            groupingDiv = document.createElement('div');
            groupingDiv.setAttribute('id', tableId+'groups');
            groupingDiv.setAttribute('class', 'groups');
            gridDiv.appendChild(groupingDiv);

            widgetDiv = document.createElement('div');
            widgetDiv.setAttribute('class', 'ui-widget-content');
            groupingDiv.appendChild(widgetDiv);

            groupingOl = document.createElement('ol');
            groupingOl.setAttribute('class', 'ui-droppable ui-sortable groupingOl');
            widgetDiv.appendChild(groupingOl);

            groupingli = document.createElement('li');
            groupingli.setAttribute('class', 'placeholder');
            groupingli.innerHTML = 'Drag a column header and drop it here to group by that column';
            groupingOl.appendChild(groupingli);
        }

        // Adding jqgrid table element
        table = document.createElement('table');
        table.setAttribute('id', tableId);
        gridDiv.appendChild(table);

        // Adding jqgrid pager element
        pager = document.createElement('div');
        pager.setAttribute('id', pagerId);
        gridDiv.appendChild(pager);
    },

    // Initialize jqgrid
    initializeGrid: function (component, event, helper) {
        // All attributes related to jqgrid features
        var tableId, pagerId, autoWidth, tableWidth, pagination, rowsPerPage, viewRecordsInfo, grouping, groupingColumns, showGroupingColumns, groupingCollapse, treeView, expandColumn, searching, searchingConfigurations, columnChooser, columnHeaders, columnModels, recordData, shortingColumnName, setTopFocus, rowList, multiselect, groupingOrder, groupText, multiselectcheckAll;
        tableId = component.get("v.TableId");
        pagerId = component.get("v.PagerId");
        autoWidth = component.get("v.AutoWidth");
        tableWidth = component.get("v.TableWidth");
        pagination = component.get("v.Pagination");
        rowsPerPage = component.get("v.RecordsToShowPerPage");
        viewRecordsInfo = component.get("v.ViewRecordsInfo");
        grouping = component.get("v.Grouping");
        if(component.get("v.showGroupingsummery") == true){
        	groupingColumns = component.get("v.GroupingColumns");
        }
        showGroupingColumns = component.get("v.ShowGroupingColumns");
        groupingCollapse = component.get("v.GroupingCollapse");
        treeView = component.get("v.TreeView");
        expandColumn = component.get("v.ExpandColumn");
        searching = component.get("v.Searching");
        searchingConfigurations = component.get("v.SearchingConfigurations");
        columnChooser = component.get("v.ColumnChooser");
        columnHeaders = component.get("v.ColumnHeaders");
        columnModels = component.get("v.ColumnModels");
        recordData = component.get("v.RecordDetails");
        shortingColumnName = component.get("v.Shortingcolumnname");
        setTopFocus = component.get("v.SetTopFocus");
        rowList = component.get("v.rowList");
        multiselect = component.get("v.multiselect");
        groupingOrder = component.get("v.groupingOrder");
        groupText = component.get("v.groupText");
        multiselectcheckAll = component.get("v.CheckAll");
        // Execute jqgrid method regarding treeview or grouping
        if (treeView) {

            if (recordData !== undefined) {
                helper.initJqGridWithTreeView(component, event, helper,
                    tableId, pagerId, autoWidth, tableWidth, pagination,
                    rowsPerPage, viewRecordsInfo, grouping, groupingColumns,
                    showGroupingColumns, groupingCollapse, treeView, expandColumn,
                    searching, searchingConfigurations, columnChooser,
                    columnHeaders, columnModels, recordData, shortingColumnName);
            }
        } else {
            helper.initJqGridWithGroupBy(component, event, helper,
                tableId, pagerId, autoWidth, tableWidth, pagination,
                rowsPerPage, viewRecordsInfo, grouping, groupingColumns,
                showGroupingColumns, groupingCollapse, treeView, expandColumn,
                searching, searchingConfigurations, columnChooser,
                columnHeaders, columnModels, recordData, shortingColumnName,
                setTopFocus, rowList, multiselect, groupingOrder, groupText, multiselectcheckAll);
        }

    },

    // Initialize jqgrid with grouping
    initJqGridWithGroupBy: function (component, event, helper,
        tableId, pagerId, autoWidth, tableWidth, pagination,
        rowsPerPage, viewRecordsInfo, grouping, groupingColumns,
        showGroupingColumns, groupingCollapse, treeView, expandColumn,
        searching, searchingConfigurations, columnChooser,
        columnHeaders, columnModels, recordData, shortingColumnName,
        setTopFocus, rowList, multiselect, groupingOrder, groupText, multiselectcheckAll) {
        
        // Script related to collapse all child grouping section
        // with its parent grouping section
        if (JQ$.jgrid) {
            JQ$.jgrid.extend({
                groupingToggle: function (hid, clickedElem) {
                    this.each(function () {
                        var JQ$t = this, p = JQ$t.p, grp = p.groupingView,
                            minusClasses = grp.minusicon, plusClasses = grp.plusicon,
                            JQ$tr = clickedElem ?
                                    JQ$(clickedElem).closest("tr.jqgroup") :
                                    JQ$("#" + JQ$.jgrid.jqID(hid)),
                            getGroupHeaderIcon = function (JQ$trElem) {
                                return JQ$trElem.find(">td>span." + "tree-wrap");
                            },
                            itemGroupingLevel, iRowStart, showDataRowsOnExpending = true,
                            JQ$groupIcon, collapsed = false, rowsToHideOrShow = [],
                            addToHideOrShow = function (JQ$elem) {
                                var i, l = JQ$elem.length;
                                for (i = 0; i < l; i++) {
                                    rowsToHideOrShow.push(JQ$elem[i]);
                                }
                            },
                            num = parseInt(JQ$tr.data("jqgrouplevel"), 10);
        
                        if (p.frozenColumns && JQ$tr.length > 0) {
                            // always get row from non-frozen column
                            iRowStart = JQ$tr[0].rowIndex;
                            JQ$tr = JQ$(JQ$t.rows[iRowStart]);
                            JQ$tr = JQ$tr.add(JQ$t.grid.fbRows[iRowStart]);
                        }
                        JQ$groupIcon = getGroupHeaderIcon(JQ$tr);
        
                        if (JQ$.jgrid.hasAllClasses(JQ$groupIcon, minusClasses)) {
                            JQ$groupIcon.removeClass(minusClasses).addClass(plusClasses);
                            collapsed = true;
                        } else {
                            JQ$groupIcon.removeClass(plusClasses).addClass(minusClasses);
                        }
                        for (JQ$tr = JQ$tr.next(); JQ$tr.length; JQ$tr = JQ$tr.next()) {
                            if (JQ$tr.hasClass("jqfoot")) {
                                itemGroupingLevel = parseInt(JQ$tr.data("jqfootlevel"), 10);
                                if (collapsed) {
                                    // hide all till the summary row of the same level.
                                    // don't hide the summary row if grp.showSummaryOnHide === true
                                    itemGroupingLevel = parseInt(JQ$tr.data("jqfootlevel"), 10);
                                    if ((!grp.showSummaryOnHide && itemGroupingLevel === num) || itemGroupingLevel > num) {
                                        addToHideOrShow(JQ$tr);
                                    }
                                    // stop hiding of rows if the footer of parent group are found
                                    if (itemGroupingLevel < num) { break; }
                                } else {
                                    if (itemGroupingLevel === num || (grp.showSummaryOnHide && itemGroupingLevel === num + 1)) {
                                        addToHideOrShow(JQ$tr);
                                    }
                                    if (itemGroupingLevel <= num) { break; }
                                }
                            } else if (JQ$tr.hasClass("jqgroup")) {
                                itemGroupingLevel = parseInt(JQ$tr.data("jqgrouplevel"), 10);
                                if (collapsed) {
                                    // stop hiding of rows if the grouping header of the next group
                                    // of the same (or higher) level are found
                                    if (itemGroupingLevel <= num) { break; }
        
                                    addToHideOrShow(JQ$tr);
                                } else {
                                    // stop next grouping header of the same lever are found
                                    if (itemGroupingLevel <= num) { break; }
                                    if (itemGroupingLevel === num + 1) {
                                        // one should display subgroupes in collaped form
                                        getGroupHeaderIcon(JQ$tr).removeClass(minusClasses).addClass(plusClasses);
                                        addToHideOrShow(JQ$tr);
                                    }
                                    // one need hide all data if subgroup is found
                                    showDataRowsOnExpending = false;
                                }
                            } else { // data
                                // we set currently no information about the level of data
                                // se we use showDataRowsOnExpending variable which will be
                                // used during expanding of data
                                if (collapsed || showDataRowsOnExpending) {
                                    // grouping data need be displayed only
                                    // if the last level group with data (no subgroups)
                                    // is expanded
                                    addToHideOrShow(JQ$tr);
                                }
                            }
                        }
                        //JQ$(rowsToHideOrShow)[collapsed ? "hide" : "show"]();
                        JQ$(rowsToHideOrShow).css("display", collapsed ? "none" : "");
                        // fix position of elements of frozen divs
                        if (p.frozenColumns) {
                            JQ$(JQ$t).triggerHandler("jqGridResetFrozenHeights", [{
                                header: {
                                    resizeDiv: false,
                                    resizedRows: {
                                        iRowStart: -1, // -1 means don't recalculate heights or rows
                                        iRowEnd: -1
                                    }
                                },
                                resizeFooter: false,
                                body: {
                                    resizeDiv: true,
                                    resizedRows: {
                                        iRowStart: iRowStart,
                                        iRowEnd: (JQ$tr.length ? JQ$tr[0].rowIndex - 1 : -1)
                                    }
                                }
                            }]);
                        }
        
                        // recalculate the width because vertical scrollbar can
                        // appears/disappears after expanding/collapsing
                        JQ$t.fixScrollOffsetAndhBoxPadding();
                        JQ$(JQ$t).triggerHandler("jqGridGroupingClickGroup", [hid, collapsed]);
                        if (JQ$.isFunction(p.onClickGroup)) {
                            p.onClickGroup.call(JQ$t, hid, collapsed);
                        }

                    });
                    return false;
                }
            });
        }
        var start = new Date().getTime();
        // Grid table and pager details
        var gridTableId, gridTable, gridPagerId, gridPager, groupingDiv, selectAllCheckbox,
            numberOfRowsPerPage, paginationText, currentGridData, searchConfig, allColumnModels, getColumnHeaderByName,
            rowNum, page, searchTextBoxStartId, searchConfigDetails, configuredColumns, intI, firstThCountflag,
            customFormatDisplayField, generateGroupingOptions, getArrayOfNamesOfGroupingColumns, groupingColumn, newHeight, currentHeight,
       		idsOfSelectedRows,updateIdsOfSelectedRows,gridindex,idsOfSelectedRowscount;
        gridTableId = '#' + tableId;
        gridTable = JQ$(gridTableId);
        gridPagerId = '#' + pagerId;
        gridPager = JQ$(gridPagerId);
        
        console.log('---gridTable---->',gridTable);
        
        if(!gridTable){
        	return;
        }
        
        // Pagination details
        numberOfRowsPerPage = -1;
        paginationText = '';
        if (pagination && rowsPerPage !== undefined) {
            numberOfRowsPerPage = rowsPerPage;
            paginationText = "Page {0} of {1}";
        }
        
        // Stored Checkbox Selected Id's
        idsOfSelectedRows = [];	
        JQ$('#'+tableId+'_gridslectedIds').val('');
        
        console.log('---399---');
        
       
        // If grid have already initialized, binding it
        currentGridData = gridTable.jqGrid('getGridParam', 'data');
        
        
        console.log('---402---');
        if (currentGridData !== undefined && currentGridData !== null) {
            // Clear all search text boxes to reset search
            searchTextBoxStartId = 'gs_';
            JQ$("input[id^=" + searchTextBoxStartId + "]").val("");
            
			idsOfSelectedRows = [];
			start = new Date().getTime();
			console.log('start ---- time --->'+start);
            rowNum = gridTable.getGridParam("rowNum");
            page = gridTable.getGridParam("page");
            gridTable.jqGrid('setGridParam', {
                datastr: recordData,
                datatype: 'jsonstring',
                rowNum: rowNum,
                page: page,
                grouping: true,
				postData: { "filters": ""},
            }).trigger('reloadGrid');
            return;
        }
    	
        // In this function we are doing 
        // Adding and removing the checkbox selected Id's
        updateIdsOfSelectedRows = function (aRowid, isSelected) {
        	/*
            // In check box selection if we want text value then we have to do following steps
            // step 1:in apex controller add the columnHeader and columnModel prefix "Id_"
            // with the required column name (reference: avPolicyCampaignAssignmentController.js (line No:1243 and 1380)).
            // step 2: in helper js dynamically add the "Id_" values like prefix "CustomID_" to record data
            // (reference: avPolicyCampaignAssignmentComponentHelper.js (line No:61 to 65))
			// This we can do directly assigning key to the required column but 
            // if any special charecters is there in the text then we will face problem (like ticket NO:re#8019).
            if(aRowid.indexOf('CustomID_') !== -1){
                var columnName = JSON.parse(columnHeaders);
                for(var i = 0; i < columnName.length; i++){
                    if(columnName[i].indexOf('Id_') !== -1){
                        columnName=columnName[i].split('_')[1];
                        break;
                    }
                }
                if(typeof columnName !== "undefined" && columnName !== null ) {
                    aRowid = gridTable.jqGrid('getCell', aRowid, columnName); 
                }
            }
            gridindex = JQ$.inArray(aRowid, idsOfSelectedRows);
            if (!isSelected && gridindex >= 0) {
                idsOfSelectedRows.splice(gridindex, 1); // Remove id from the list
            } else if (gridindex < 0) {
                idsOfSelectedRows.push(aRowid);	// Add id from the list
            }
            JQ$('#'+tableId+'_gridslectedIds').val(idsOfSelectedRows);
			*/
        };
        // Execute jqgrid with attributes 
        gridTable.jqGrid({
            colNames: JSON.parse(columnHeaders),
            colModel: JSON.parse(columnModels),
            datastr: recordData,
            datatype: 'jsonstring',
            rowNum: numberOfRowsPerPage,
            search: false,
            grouping: true,
            ignoreCase: true,
            height: component.get("v.Height"),
            width: tableWidth,
            rowNum: rowsPerPage,
            pager: gridPagerId,
            viewrecords: viewRecordsInfo,
            multiselect: multiselect,
            autowidth: autoWidth,
            shrinkToFit: component.get("v.shrinkToFit"),
            autoencode: true,
            toppager: false,
            pgbuttons: pagination,
            pgtext: paginationText,
            gridview: true,
            loadonce: true,
            //sortname: 'Name',
            scroll: true,
            viewsortcols : [true,'vertical',true],
            groupingView: {
                groupField: groupingColumns,
                groupText: groupText,
                groupCollapse: groupingCollapse,
                groupColumnShow: showGroupingColumns,
                groupSummary : [true],
                groupDataSorted: true,
                groupOrder: groupingOrder,
                showSummaryOnHide: true,
                groupSummaryPos: component.get("v.groupSummaryPos"),
                plusicon: 'ui-icon-circle-plus',
                minusicon: 'ui-icon-circle-minus'
            },
            rowList: rowList,
            processing: true,
            loadtext: "Loading...",
            hidegrid: false,
            emptyrecords: 'No records to view', // ToDo: Change this to atrribute 
            beforeSelectRow: function (rowid, e) {
                if(component.get('v.isCheckboxEditable')){
                    var cellindex = JQ$.jgrid.getCellIndex(JQ$(e.target).closest("td"));
                    var colNames = JQ$(gridTableId).jqGrid("getGridParam", "colModel");
                    var colNameAttr = colNames[cellindex];
                    if(JQ$(e.target).is(":checkbox")){
                        if(JQ$(e.target).is(":checked")){
                            JQ$(gridTableId).jqGrid("setCell", rowid, colNameAttr.name, "true");
                        }else{
                            JQ$(gridTableId).jqGrid("setCell", rowid, colNameAttr.name, "false");
                        }
                    }
                }
                if(multiselectcheckAll===false && multiselect === false){
					JQ$(gridTableId).jqGrid('resetSelection');
					return (true);
				}
				
				if(component.get('v.singleSelectGrouping')){
				 var $this = JQ$(this),
                        selarrrow = $this.jqGrid("getGridParam", "selarrrow"),
                        $tr = JQ$(e.target).closest("tr.jqgrow"),
                        otherIdsOfTheGroup;
            
                    if ($tr.length > 0) {
                        otherIdsOfTheGroup =
                            // get all rows of the group before the current
                            $tr.prevUntil("tr.jqgroup")
                                // add all rows of the group after the current
                                .add($tr.nextUntil("tr.jqgroup"))
                                // enum all the rows of the group without the current
                                .map(function () {
                                    // test whether the rowid is already selected
                                    if (JQ$.inArray(this.id, selarrrow) >= 0) {
                                        // add the rowid to the array of returned values
                                        return this.id;
                                    }
                                });
                        // otherIdsOfTheGroup contains the array of rowids of the rows
                        // from the same group, which are already selected
                        if (otherIdsOfTheGroup.length > 0) {
                            JQ$.each(otherIdsOfTheGroup, function () {
                                $this.jqGrid("resetSelection", this);
                            });
                        }
                    }
                    return true; // allow selection
                }
				
            },
            // Single Check box selection in Grid
            onSelectRow: function(aRowid, isSelected){
                if(multiselectcheckAll===true){
                	/*updateIdsOfSelectedRows(aRowid, isSelected); 
	                	// all check boxes are checked in the grid current pge then header check box is checked
	                    if(gridTable.jqGrid('getGridParam','selarrrow').length===gridTable.jqGrid('getDataIDs').length){
	                        JQ$('#cb_'+tableId+'.cbox').prop('checked', 'checked');   
	                    }
            	 	*/
                }
            },
            // Check all Check box selection in Grid
            onSelectAll: function (aRowids, isSelected) {
                /*
                var aRowid;
                if(multiselectcheckAll===true){
                    for (intI = 0, idsOfSelectedRowscount = aRowids.length; intI < idsOfSelectedRowscount; intI++) {
                        aRowid = aRowids[intI];
                        updateIdsOfSelectedRows(aRowid, isSelected);
                    }
                }
				*/
            },
            onPaging: function (pgButton) {
                
            },
            loadComplete: function (data) {
            	
                console.log('---initJqGridWithGroupBy--loadComplete--- 1 ');
                //JQ$(gridTableId).jqGrid('avJqGridGroupingToggle');
                
                /* this code is used to enable grid in edit mode */
                var $this = JQ$(this), ids = $this.jqGrid('getDataIDs'), i, l = ids.length;
			    for (i = 0; i < l; i++) {
			        $this.jqGrid('editRow', ids[i], true);
			    }
				
			},
			gridComplete: function() {
                var end = new Date().getTime();
                console.log('time taken:'+(end - start) / 1000);
                if($A.get("e.c:BT_SpinnerEvent")) $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                
            }
        });

        // Initialize jqgrid with record data
        if (recordData !== undefined && recordData.trim() !== '' && recordData.trim() !== '[]') {
           
            //Set height of grid
            currentHeight =  JQ$(".ui-jqgrid-bdiv").height();
            newHeight = component.get("v.Height");
            if(newHeight !== 'auto' && parseInt(newHeight,10) < parseInt(currentHeight,10) && gridTable){
                gridTable.jqGrid('setGridHeight',newHeight);
            }
            
            // Allowing searching for jqgrid columns
            if (searching) {
                gridTable.jqGrid('filterToolbar', {
                    searchOnEnter: false,
                    enableClear: true,
                    afterSearch: function () {
                       
                    },
                    beforSearch: function() {
                    }
                });
            }

            // Allowing searching for columns and assigning
            // title to search box of column based on
            // searching configuration
            if (searchingConfigurations !== undefined) {

                searchConfigDetails = JSON.parse(searchingConfigurations);

                for (intI = 0; intI < searchConfigDetails.length; intI += 1) {
                    searchConfig = searchConfigDetails[intI];
                    configuredColumns += searchConfig.strColumnModelName + ',';
                    gridTable.jqGrid('setColProp', searchConfig.strColumnModelName, {
                        search: searchConfig.blnAllowSearch
                    });
                }

                gridTable.jqGrid('filterToolbar', {
                    searchOnEnter: false,
                    enableClear: true
                });
            }
        }

        JQ$(window).on("resize", function () {
            var newWidth = JQ$(gridTableId).closest(".ui-jqgrid").parent().width();
            gridTable.jqGrid("setGridWidth", newWidth - 2, true);
        });

    },

    // Initiaize jqgrid with tree view structure
    initJqGridWithTreeView: function (component, event, helper,
        tableId, pagerId, autoWidth, tableWidth, pagination,
        rowsPerPage, viewRecordsInfo, grouping, groupingColumns,
        showGroupingColumns, groupingCollapse, treeView, expandColumn,
        searching, searchingConfigurations, columnChooser,
        columnHeaders, columnModels, recordData) {
        // Grid table and pager details
        var gridTableId, gridTable, gridPagerId, gridPager, selectAllCheckbox;
        gridTableId = '#' + tableId;
        gridTable = JQ$(gridTableId);
        gridPagerId = '#' + pagerId;
        gridPager = JQ$(gridPagerId);

        // Execute jqgrid method with attributes
        gridTable.jqGrid({
            datatype: "local",
            colNames: JSON.parse(columnHeaders),
            colModel: JSON.parse(columnModels),
            ignoreCase: true,
            height: component.get("v.Height"),
            width: tableWidth,
            pager: gridPagerId,
            viewrecords: viewRecordsInfo,
            multiselect: true,
            autowidth: autoWidth,
            autoencode: true,
            toppager: false,
            pgbuttons: pagination,
            gridview: true,
            sortname: 'id',
            grouping: false,
            treeGrid: true,
            loadonce: true,
            treeGridModel: 'adjacency',
            treedatatype: 'local',
            ExpandColumn: expandColumn,
            processing: true,
            hidegrid: false,
            emptyrecords: component.get("v.lblNoColumns"),
            beforeSelectRow: function (rowid, e) {
                if (rowid.toUpperCase().indexOf('_NOTSELECTABLE') !== -1) {
                    return (false);
                } else {
                    gridTable.jqGrid('resetSelection');
                    return (true);
                }
            }
        });

        // Initialize jqgrid with record data
        if (recordData !== undefined && recordData.trim() !== '' && recordData.trim() !== '[]') {

            recordData = JSON.parse(recordData);
            gridTable[0].addJSONData({
                total: 1,
                page: 1,
                records: recordData.length,
                rows: recordData
            });

            // Remove select all checkbox
            selectAllCheckbox = document.getElementById('jqgh_' + tableId + '_cb');
            if (selectAllCheckbox !== null && selectAllCheckbox !== undefined) {
                selectAllCheckbox.parentNode.removeChild(selectAllCheckbox);
            }

        }

        JQ$(window).on("resize", function () {
        	console.log('---resize---');
            var newWidth = JQ$(gridTableId).closest(".ui-jqgrid").parent().width();
            gridTable.jqGrid("setGridWidth", newWidth - 2, true);
        });

    },

    // Preaparing dynamic link for records
    // For example, with lookup type of field it will display
    // record name column and open the link with record id
    prepareDynamicLink: function (UiTheme, cellValue, options, rowData, urlField, addSlash, target) {
        if (urlField !== undefined && urlField.trim() !== '' && cellValue !== undefined && cellValue.trim() !== '') {

            var href, flagForUrl, urlFields, intI;
            flagForUrl = false;
            if (rowData[urlField] === null && urlField.indexOf('.') !== -1) {
                href = rowData;
                urlFields = urlField.split('.');
                for (intI = 0; intI < urlFields.length; intI += 1) {
                    if (href !== undefined && href[urlFields[intI]] !== undefined) {
                        href = href[urlFields[intI]];
                    }
                }
                flagForUrl = true;
            } else if (rowData[urlField] !== undefined) {
                href = rowData[urlField];
                if (href === '') {
                    return '<span>' + JQ$('<div/>').text(cellValue).html() + '</span>';
                }
                flagForUrl = true;
            } else {
                href = cellValue;
            }

            if (addSlash === true || addSlash === 'true') {
                href = '/' + href;
            }
			if(urlField !== 'RecordTypeId') {
                if (UiTheme === 'Theme4d' && $A.get("e.force:navigateToURL")) {
                    if (flagForUrl) {
                        return '<a class="avBlueLink navigateToURL" data-href="' + href + '" onclick="javascript:sforce.one.navigateToURL(\'' + href + '\');">' + JQ$('<div/>').text(cellValue).html() + '</a>';
                    }
                    return '<a class="avBlueLink navigateToURL" data-href="' + href + '"  onclick="javascript:sforce.one.navigateToSObject(\'' + href + '\',\'true\');">' + JQ$('<div/>').text(cellValue).html() + '</a>';
                }
                return '<a class="avBlueLink" href="' + href + '"  target="' + target + '">' + JQ$('<div/>').text(cellValue).html() + '</a>';
            } else if(urlField === 'RecordTypeId'){
               return JQ$('<div/>').text(cellValue).html();
            }
        } else if (cellValue === null || cellValue === undefined) {
            return '';
        }
    },


    addSelectedRecordToRHS: function (component, event, helper, Ids){
    	var action;
		action = component.get("c.addRecordToRHS");
        action.setParams({
            ids: Ids,
            GridType: component.get("v.gridType"),
            parentId: component.get("v.parentId")
        });
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
            	var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
	                "title": "",
	                "message": "Added succesfully.",
	                "type": "success"
	            });
	            toastEvent.fire();
	            component.refreshData();
			    
            } else {
            	var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
	                "title": "Error!",
	                "message": response.getError()[0].message,
	                "type": "Error"
	            });
	            toastEvent.fire();
            	
            }
        });
        
        $A.enqueueAction(action);
    },
    
    deleteSelectedRecordFromRHS: function (component, event, helper, Ids){
    	var action;
		action = component.get("c.deleteRecordRHS");
        action.setParams({
            ids: Ids,
            GridType: component.get("v.gridType"),
            parentId: component.get("v.parentId")
        });
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
            	var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
	                "title": "",
	                "message": "Removed succesfully.",
	                "type": "success"
	            });
	            toastEvent.fire();
	            component.refreshData();
			    
            } else {
            	var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
	                "title": "Error!",
	                "message": response.getError()[0].message,
	                "type": "Error"
	            });
	            toastEvent.fire();
            	
            }
        });
        
        $A.enqueueAction(action);
    }

})();