/* globals bryntum : true */
import insertUpdateTask from "@salesforce/apex/BT_NewGanttChartCls.insertUpdateTask";

export default (base) =>
  class GanttToolbar extends base {
    static get $name() {
      return "GanttToolbar";
    }
    // Called when toolbar is added to the Gantt panel
    set parent(parent) {
      super.parent = parent;
      const me = this;

      me.gantt = parent;
      //this.gantt.zoomIn();
      //this.gantt.zoomIn();
      /*this.gantt.zoomToFit({
            leftMargin  : 60,
            rightMargin : 60
        });*/
      parent.project.on({
        /*commented by sai */
        //load: 'zoomInOnLoad',
        load: "updateStartDateField",
        //refresh    :  this.gantt.scrollToDate(this.widgetMap.startDateField, { block : 'center', animate : 500 }),
        refresh: "refreshData",
        /*commented by sai */
        thisObj: me,
      });
      parent.project.stm.on({
        recordingStop: "updateUndoRedoButtons",
        restoringStop: "updateUndoRedoButtons",
        stmDisabled: "updateUndoRedoButtons",
        queueReset: "updateUndoRedoButtons",
        thisObj: me,
      });
      me.styleNode = document.createElement("style");
      document.head.appendChild(me.styleNode);
    }
    get parent() {
      return super.parent;
    }

    static get defaultConfig() {
      console.log(parent);
      var centerDate = parent; //new Date(); //this.gantt.project.startDate;
      return {
        items: [
          {
            type: "buttonGroup",
            items: [
              {
                type: "button",
                color: "b-green",
                ref: "addTaskButton",
                icon: "b-fa b-fa-plus",
                text: "Create",
                tooltip: "Create new task",
                onAction: "up.onAddTaskClick",
              },
            ],
          },
          {
            type: "buttonGroup",
            items: [
              /* {
                            type     : 'button',
                            color    : 'b-blue',//b-blue',
                            ref      : 'editTaskButton',
                            icon     : 'b-fa b-fa-pen',
                            text     : 'Edit',
                            tooltip  : 'Edit selected task',
                            onAction : 'up.onEditTaskClick'
                        }, */
              {
                type: "button",
                color: "b-blue",
                ref: "undoBtn",
                icon: "b-icon b-fa b-fa-undo",
                tooltip: "Undo",
                disabled: true,
                width: "2em",
                onAction: "up.onUndoClick",
              },
              {
                type: "button",
                color: "b-blue",
                ref: "redoBtn",
                icon: "b-icon b-fa b-fa-redo",
                tooltip: "Redo",
                disabled: true,
                width: "2em",
                onAction: "up.onRedoClick",
              },
            ],
          },
          {
            type: "buttonGroup",
            items: [
              {
                type: "button",
                color: "b-blue",
                ref: "expandAllButton",
                icon: "b-fa b-fa-angle-double-down",
                tooltip: "Expand all",
                onAction: "up.onExpandAllClick",
              },
              {
                type: "button",
                color: "b-blue",
                ref: "collapseAllButton",
                icon: "b-fa b-fa-angle-double-up",
                tooltip: "Collapse all",
                onAction: "up.onCollapseAllClick",
              },
            ],
          },
          {
            type: "buttonGroup",
            items: [
              {
                type: "button",
                color: "b-blue",
                ref: "zoomInButton",
                icon: "b-fa b-fa-search-plus",
                tooltip: "Zoom in",
                onAction: "up.onZoomInClick",
              },
              {
                type: "button",
                color: "b-blue",
                ref: "zoomOutButton",
                icon: "b-fa b-fa-search-minus",
                tooltip: "Zoom out",
                onAction: "up.onZoomOutClick",
              },
              {
                type: "button",
                color: "b-blue",
                ref: "zoomToFitButton",
                icon: "b-fa b-fa-compress-arrows-alt",
                tooltip: "Zoom to fit",
                onAction: "up.onZoomToFitClick",
              },
              {
                type: "button",
                color: "b-blue",
                ref: "previousButton",
                icon: "b-fa b-fa-angle-left",
                tooltip: "Previous time span",
                onAction: "up.onShiftPreviousClick",
              },
              {
                type: "button",
                color: "b-blue",
                ref: "nextButton",
                icon: "b-fa b-fa-angle-right",
                tooltip: "Next time span",
                onAction: "up.onShiftNextClick",
              },
            ],
          },
          {
            type: "buttonGroup",
            items: [
              {
                type: "button",
                color: "b-blue",
                ref: "featuresButton",
                icon: "b-fa b-fa-tasks",
                text: "Features",
                tooltip: "Toggle features",
                toggleable: true,
                menu: {
                  onItem: "up.onFeaturesClick",
                  onBeforeShow: "up.onFeaturesShow",
                  items: [
                    {
                      text: "Draw dependencies",
                      feature: "dependencies",
                      checked: false,
                    },
                    {
                      text: "Task labels",
                      feature: "labels",
                      checked: false,
                    },
                    {
                      text: "Project lines",
                      feature: "projectLines",
                      checked: false,
                    },
                    {
                      text: "Highlight non-working time",
                      feature: "nonWorkingTime",
                      checked: false,
                    },
                    /* {
                                        text    : 'Enable cell editing',
                                        feature : 'cellEdit',
                                        checked : false
                                    }, */
                    /* {
                                        text    : 'Show baselines',
                                        feature : 'baselines',
                                        checked : false
                                    },
                                    {
                                        text    : 'Show rollups',
                                        feature : 'rollups',
                                        checked : false
                                    },
                                    {
                                        text    : 'Show progress line',
                                        feature : 'progressLine',
                                        checked : false
                                    }, */
                    {
                      text: "Hide schedule",
                      cls: "b-separator",
                      subGrid: "normal",
                      checked: false,
                    },
                  ],
                },
              },
              {
                type: "button",
                color: "b-blue",
                ref: "settingsButton",
                icon: "b-fa b-fa-cogs",
                text: "Settings",
                tooltip: "Adjust settings",
                toggleable: true,
                menu: {
                  type: "popup",
                  anchor: true,
                  cls: "settings-menu",
                  layoutStyle: {
                    flexDirection: "column",
                  },
                  onBeforeShow: "up.onSettingsShow",
                  items: [
                    {
                      type: "slider",
                      ref: "rowHeight",
                      text: "Row height",
                      width: "12em",
                      showValue: true,
                      min: 30,
                      max: 70,
                      onInput: "up.onSettingsRowHeightChange",
                    },
                    {
                      type: "slider",
                      ref: "barMargin",
                      text: "Bar margin",
                      width: "12em",
                      showValue: true,
                      min: 0,
                      max: 10,
                      onInput: "up.onSettingsMarginChange",
                    },
                  ],
                },
              },
              {
                type: "button",
                color: "b-blue",
                ref: "criticalPathsButton",
                icon: "b-fa b-fa-fire",
                text: "Critical paths",
                tooltip: "Highlight critical paths",
                toggleable: true,
                onAction: "up.onCriticalPathsClick",
              },
            ],
          },
          /* {
                    type      : 'datefield',
                    ref       : 'startDateField',
                    label     : 'Project start',
                    // required  : true, (done on load)
                    flex      : '1 2 17em',
                    listeners : {
                        change : 'up.onStartDateChange'
                    }
                },*/
          {
            label: "Scroll to date",
            inputWidth: "7em",
            width: "auto",
            type: "datefield",
            value: new Date(),
            step: "1w",
            listeners: {
              change: "up.onscrollToDate",
            },
            highlightExternalChange: false,
          },
          {
            type: "buttonGroup",
            items: [
              {
                type: "button",
                color: "b-blue",
                ref: "saveDataButton",
                icon: "b-fa b-fa-save",
                text: "Save Changes",
                onAction: "up.onSaveClick",
              },
            ],
          },
          {
            type: "buttonGroup",
            items: [
              {
                type: "button",
                color: "b-blue",
                ref: "importScheduleLines",
                icon: "b-fa b-fa-file-import", //file-upload
                text: "Import Schedule Lines",
                onAction: "up.onImportScheduleLines",
              },
            ],
          },
          {
            type: "buttonGroup",
            items: [
              {
                type: "button",
                color: "b-blue",
                ref: "importMasterSchedule",
                icon: "b-fa b-fa-download",
                text: "Import Master Schedule",
                onAction: "up.onImportMasterSchedule",
              },
            ],
          },

          /*{
                    type                 : 'textfield',
                    ref                  : 'filterByName',
                    cls                  : 'filter-by-name',
                    flex                 : '1 1 12.5em',
                    // Label used for material, hidden in other themes
                    label                : 'Find tasks by name',
                    // Placeholder for others
                    placeholder          : 'Find tasks by name',
                    clearable            : true,
                    keyStrokeChangeDelay : 100,
                    triggers             : {
                        filter : {
                            align : 'end',
                            cls   : 'b-fa b-fa-filter'
                        }
                    },
                    onChange : 'up.onFilterChange'
                }*/
        ],
      };
    }
    updateUndoRedoButtons() {
      const { stm } = this.gantt.project,
        { undoBtn, redoBtn } = this.widgetMap,
        redoCount = stm.length - stm.position;
      undoBtn.badge = stm.position || "";
      redoBtn.badge = redoCount || "";
      undoBtn.disabled = !stm.canUndo;
      redoBtn.disabled = !stm.canRedo;
    }
    updateStartDateField() {
      this.gantt.zoomIn();
      this.gantt.zoomIn();
      const startDateField = this.widgetMap.startDateField;
      /* if(startDateField){
            startDateField.value = this.gantt.project.startDate;
        // This handler is called on project.load/propagationComplete, so now we have the
        // initial start date. Prior to this time, the empty (default) value would be
        // flagged as invalid.
        startDateField.required = false; //true
        } */

      //startDateField.value = this.gantt.project.startDate;
      if (this.gantt.project.startDate) {
        this.gantt.scrollToDate(this.gantt.project.startDate, {
          block: "center",
          animate: 0,
        });
      }

      // This handler is called on project.load/propagationComplete, so now we have the
      // initial start date. Prior to this time, the empty (default) value would be
      // flagged as invalid.
      //startDateField.required = false; //true
    }
    refreshData() {
      //this.gantt.zoomIn();
      const startDateField = this.widgetMap.startDateField;
      if (startDateField) {
        startDateField.value = this.gantt.project.startDate;
        // This handler is called on project.load/propagationComplete, so now we have the
        // initial start date. Prior to this time, the empty (default) value would be
        // flagged as invalid.
        startDateField.required = false; //true
      }
      console.log(this.gantt); //.data
      //console.log(this.ganttCartData)
      //startDateField.value = this.gantt.project.startDate;
      //this.gantt.scrollToDate(this.gantt.project.startDate, { block : 'center', animate : 0 });

      // This handler is called on project.load/propagationComplete, so now we have the
      // initial start date. Prior to this time, the empty (default) value would be
      // flagged as invalid.
      //startDateField.required = false; //true
    }
    onSaveClick() {
      var ganttfullData = this.gantt.data;
      console.log(this.gantt.data);
      var ganttRowData = [];
      var taskData = JSON.parse(this.gantt.taskStore.json);
      var dependenciesData = JSON.parse(this.gantt.dependencyStore.json);
      var resourceData = JSON.parse(this.gantt.assignmentStore.json);
      console.log("taskData-->", taskData);
      console.log("dependenciesData-->", dependenciesData);
      console.log("resourceData-->", resourceData);
      var thatthis = this.gantt.callGanttComponent;
      var rowData = [];
      function getChildren(data) {
        if (data.children) {
          for (var i = 0; i < data.children.length; i++) {
            getChildren(data.children[i]);
          }
        } else {
          rowData.push(data);
        }
      }
      getChildren(taskData[0]);
      console.log(rowData);
      var updateDataList = [];
      var insertData = [];
      for (var i = 0; i < rowData.length; i++) {
        var updateData = {};
        var endDate;
        if (rowData[i]["name"] != "Milestone Complete") {
          endDate = new Date(rowData[i].endDate);
          endDate.setDate(endDate.getDate() - 1);
        } else {
          endDate = new Date(rowData[i].endDate);
          //endDate.setDate(endDate.getDate() + 1)
        }

        rowData[i].endDate = endDate;
        updateData["Id"] = rowData[i]["id"];
        updateData["Name"] = rowData[i]["name"];
        updateData["buildertek__Order__c"] = i + 1;
        //var startdate = new Date(rowData[i]['startDate'])
        var enddate = new Date(rowData[i]["endDate"])
          .toLocaleDateString()
          .split("/");
        updateData["buildertek__Start__c"] =
          rowData[i]["startDate"].split("T")[0];
        updateData["buildertek__Finish__c"] =
          enddate[2] + "-" + enddate[1] + "-" + enddate[0];
        updateData["buildertek__Duration__c"] = rowData[i]["duration"];
        updateData["buildertek__Completion__c"] = rowData[i]["percentDone"];
        if (rowData[i]["parentId"].split("_")[1]) {
          updateData["buildertek__Phase__c"] =
            rowData[i]["parentId"].split("_")[1];
        }
        var filledDependency = false;
        for (var j = 0; j < dependenciesData.length; j++) {
          if (dependenciesData[j]["to"] == rowData[i]["id"]) {
            if (dependenciesData[j]["id"].indexOf("_generated") >= 0) {
              updateData["buildertek__Dependency__c"] =
                dependenciesData[j]["from"];
            } else {
              updateData["buildertek__Dependency__c"] =
                dependenciesData[j]["from"];
            }
            filledDependency = true;
          }
          if (!filledDependency) {
            updateData["buildertek__Dependency__c"] = "";
          }
        }
        updateDataList.push(updateData);
      }
      this.gantt.callGanttComponent.callinsertUpdateTaskList(updateDataList);
      /*
            dependency types 
            type-1 : start-start
            type-2 : start-end
            type-3 : end-start //generally used
            type-4 : end-end
        */

      /* for(let i=0;i<ganttfullData.length;i++){
           // if(ganttfullData[i].type="Task")
           console.log(ganttfullData[i])
            if(!ganttfullData[i]._data.endDate){
                ganttfullData[i]._data.endDate = ganttfullData[i].endDate
            }
            if(!ganttfullData[i]._data.startDate){
                ganttfullData[i]._data.startDate = ganttfullData[i].startDate
            }
            console.log(ganttfullData[i].allDependencies)
            // for dependencies
            ganttfullData[i]._data['predecessors'] = [];
            for(let j = 0;j<ganttfullData[i].allDependencies.length;j++){
                console.log(ganttfullData[i].allDependencies[j]._data.fromTask)
                console.log(ganttfullData[i]._data.id)
                if(ganttfullData[i].allDependencies[j]._data.fromTask && ganttfullData[i]._data.id != ganttfullData[i].allDependencies[j]._data.fromTask){
                    ganttfullData[i]._data['predecessors'].push(ganttfullData[i].allDependencies[j]._data.fromEvent._data)
                }
            }
            console.log(ganttfullData[i]._data['predecessors'])
            // for resources
             
            ganttRowData.push(ganttfullData[i]._data)
            //console.log(ganttfullData[i]._data)
        }*/
      console.log(this.gantt.taskStore);
      console.log(this.gantt.dependencyStore);
      console.log("dfr", ganttRowData); //send only task rows to apex and update/insert them
      //for newly added tasks we getting id="_generated+index" so while sending data to apex we can check to insert them
    }
    onImportMasterSchedule() {
      this.gantt.callGanttComponent.openMasterSchedule();
    }
    onImportScheduleLines() {
      this.gantt.callGanttComponent.openScheduleLines();
    }
    // region controller methods
    async onAddTaskClick() {
      /* const
            { gantt } = this,
            added = gantt.taskStore.rootNode.appendChild({ name : 'New task', duration : 1 });
            //start date and end date are not setting when adding task, only duration and name are assigning
        // run propagation to calculate new task fields
        await gantt.project.propagate();
        // scroll to the added task
        await gantt.scrollRowIntoView(added);
        if (added) {
             gantt.editTask(added);
        }
        gantt.features.cellEdit.startEditing({
            record : added,
            field  : 'name'
        }); */
      this.gantt.callGanttComponent.addNewTask();
    }
    onEditTaskClick() {
      const { gantt } = this;
      if (gantt.selectedRecord) {
        gantt.editTask(gantt.selectedRecord);
      } else {
        bryntum.gantt.Toast.show("First select the task you want to edit");
      }
    }
    onExpandAllClick() {
      this.gantt.expandAll();
    }
    onCollapseAllClick() {
      this.gantt.collapseAll();
    }
    onZoomInClick() {
      this.gantt.zoomIn();
    }
    onZoomOutClick() {
      this.gantt.zoomOut();
    }
    onZoomToFitClick() {
      this.gantt.zoomToFit({
        leftMargin: 50,
        rightMargin: 50,
      });
    }
    onShiftPreviousClick() {
      this.gantt.shiftPrevious();
    }
    onShiftNextClick() {
      this.gantt.shiftNext();
    }

    /* onStartDateChange({ value, oldValue }) {
        if (!oldValue) { // ignore initial set
            return;
        }
        this.gantt.startDate = bryntum.gantt.DateHelper.add(value, -1, 'week');
        this.gantt.project.setStartDate(value);
    } */
    onscrollToDate({ userAction, value }) {
      if (userAction) {
        this.gantt.scrollToDate(value, { block: "center", animate: 500 });
      }
    }

    onFilterChange({ value }) {
      if (value === "") {
        this.gantt.taskStore.clearFilters();
      } else {
        value = value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
        this.gantt.taskStore.filter({
          filters: (task) =>
            task.name && task.name.match(new RegExp(value, "i")),
          replace: true,
        });
      }
    }
    onFeaturesClick({ source: item }) {
      const { gantt } = this;
      if (item.feature) {
        const feature = gantt.features[item.feature];
        feature.disabled = !feature.disabled;
      } else if (item.subGrid) {
        const subGrid = gantt.subGrids[item.subGrid];
        subGrid.collapsed = !subGrid.collapsed;
      }
    }
    onFeaturesShow({ source: menu }) {
      const { gantt } = this;

      menu.items.forEach((item) => {
        const { feature } = item;
        if (feature) {
          // a feature might be not presented in the gantt
          // (the code is shared between "advanced" and "php" demos which use a bit different set of features)
          if (gantt.features[feature]) {
            item.checked = !gantt.features[feature].disabled;
          }
          // hide not existing features
          else {
            item.hide();
          }
        } else {
          item.checked = gantt.subGrids[item.subGrid].collapsed;
        }
      });
    }
    onSettingsShow({ source: menu }) {
      const { gantt } = this,
        { widgetMap } = menu;
      widgetMap.rowHeight.value = gantt.rowHeight;
      widgetMap.barMargin.value = gantt.barMargin;
      widgetMap.barMargin.max = gantt.rowHeight / 2 - 5;
    }
    onSettingsRowHeightChange({ value }) {
      this.gantt.rowHeight = value;
      this.widgetMap.settingsButton.menu.widgetMap.barMargin.max =
        value / 2 - 5;
    }
    onSettingsMarginChange({ value }) {
      this.gantt.barMargin = value;
    }
    onCriticalPathsClick({ source }) {
      this.gantt.features.criticalPaths.disabled = !source.pressed;
    }
    onUndoClick() {
      if (this.gantt.project.stm.canUndo) {
        this.gantt.project.stm.undo();
      }
    }
    onRedoClick() {
      if (this.gantt.project.stm.canRedo) {
        this.gantt.project.stm.redo();
      }
    }
  };