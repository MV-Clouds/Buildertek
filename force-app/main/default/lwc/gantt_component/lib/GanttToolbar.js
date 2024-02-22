/* globals bryntum : true */
import { convertJSONtoApexData,setResourceDataForApexData } from "../gantt_componentHelper";
export default base => class GanttToolbar extends base {
    static get $name() {
        return 'GanttToolbar';
    }

    // Called when toolbar is added to the Gantt panel
    set parent(parent) {
        super.parent = parent;

        const me = this;

        me.gantt = parent;

        parent.project.on({
            load    : 'updateStartDateField',
            refresh : 'updateStartDateField',
            thisObj : me
        });

        parent.project.stm.on({
            recordingStop : 'updateUndoRedoButtons',
            restoringStop : 'updateUndoRedoButtons',
            stmDisabled   : 'updateUndoRedoButtons',
            queueReset    : 'updateUndoRedoButtons',
            thisObj       : me
        });

        me.styleNode = document.createElement('style');
        document.head.appendChild(me.styleNode);
    }

    get parent() {
        return super.parent;
    }

    static get defaultConfig() {
        return {
            items : [
                {
                    type  : 'buttonGroup',
                    items : [
                        {
                            type     : 'button',
                            color    : 'b-green',
                            ref      : 'addTaskButton',
                            icon     : 'b-fa b-fa-plus',
                            text     : 'Create',
                            tooltip  : 'Create new task',
                            onAction : 'up.onAddTaskClick'
                        }
                    ]
                },
                {
                    type  : 'buttonGroup',
                    items : [
                        {
                            type     : 'button',
                            color    : 'b-blue',
                            ref      : 'editTaskButton',
                            icon     : 'b-fa b-fa-pen',
                            text     : 'Edit',
                            tooltip  : 'Edit selected task',
                            onAction : 'up.onEditTaskClick'
                        },
                        {
                            type     : 'button',
                            color    : 'b-blue',
                            ref      : 'undoBtn',
                            icon     : 'b-icon b-fa b-fa-undo',
                            tooltip  : 'Undo',
                            disabled : true,
                            width    : '2em',
                            onAction : 'up.onUndoClick'
                        },
                        {
                            type     : 'button',
                            color    : 'b-blue',
                            ref      : 'redoBtn',
                            icon     : 'b-icon b-fa b-fa-redo',
                            tooltip  : 'Redo',
                            disabled : true,
                            width    : '2em',
                            onAction : 'up.onRedoClick'
                        }
                    ]
                },
                {
                    type  : 'buttonGroup',
                    items : [
                        {
                            type     : 'button',
                            color    : 'b-blue',
                            ref      : 'expandAllButton',
                            icon     : 'b-fa b-fa-angle-double-down',
                            tooltip  : 'Expand all',
                            onAction : 'up.onExpandAllClick'
                        },
                        {
                            type     : 'button',
                            color    : 'b-blue',
                            ref      : 'collapseAllButton',
                            icon     : 'b-fa b-fa-angle-double-up',
                            tooltip  : 'Collapse all',
                            onAction : 'up.onCollapseAllClick'
                        }
                    ]
                },
                {
                    type  : 'buttonGroup',
                    items : [
                        {
                            type     : 'button',
                            color    : 'b-blue',
                            ref      : 'zoomInButton',
                            icon     : 'b-fa b-fa-search-plus',
                            tooltip  : 'Zoom in',
                            onAction : 'up.onZoomInClick'
                        },
                        {
                            type     : 'button',
                            color    : 'b-blue',
                            ref      : 'zoomOutButton',
                            icon     : 'b-fa b-fa-search-minus',
                            tooltip  : 'Zoom out',
                            onAction : 'up.onZoomOutClick'
                        },
                        {
                            type     : 'button',
                            color    : 'b-blue',
                            ref      : 'zoomToFitButton',
                            icon     : 'b-fa b-fa-compress-arrows-alt',
                            tooltip  : 'Zoom to fit',
                            onAction : 'up.onZoomToFitClick'
                        },
                        {
                            type     : 'button',
                            color    : 'b-blue',
                            ref      : 'previousButton',
                            icon     : 'b-fa b-fa-angle-left',
                            tooltip  : 'Previous time span',
                            onAction : 'up.onShiftPreviousClick'
                        },
                        {
                            type     : 'button',
                            color    : 'b-blue',
                            ref      : 'nextButton',
                            icon     : 'b-fa b-fa-angle-right',
                            tooltip  : 'Next time span',
                            onAction : 'up.onShiftNextClick'
                        }
                    ]
                }
                ,{
                  type                 : 'textfield',
                  ref                  : 'filterByName',
                  cls                  : 'filter-by-name',
                  // flex                 : '1 1 12.5em',
                  width: '17em',
                  // Label used for material, hidden in other themes
                  // Placeholder for others
                  placeholder          : 'Name',
                  clearable            : true,
                  keyStrokeChangeDelay : 100,
                  triggers             : {
                      filter : {
                          align : 'end',
                          cls   : 'b-fa b-fa-filter'
                      }
                  },
                  onChange : 'up.onFilterChange'
              },
              {
                type      : 'datefield',
                ref       : 'startDateField',
                label     : 'Project start',
                // required  : true, (done on load)
                flex      : '1 0 17em',
                width     : '17em',
                height    : '3em',
                listeners : {
                    change : 'up.onStartDateChange'
                }
            },
                {
                    type  : 'buttonGroup',
                    items : [
                        {
                            type       : 'button',
                            color      : 'b-blue',
                            ref        : 'featuresButton',
                            icon       : 'b-fa b-fa-tasks',
                            text       : 'Features',
                            tooltip    : 'Toggle features',
                            toggleable : true,
                            menu       : {
                                onItem       : 'up.onFeaturesClick',
                                onBeforeShow : 'up.onFeaturesShow',
                                items        : [
                                    {
                                        text    : 'Draw dependencies',
                                        feature : 'dependencies',
                                        checked : false
                                    },
                                    {
                                        text    : 'Task labels',
                                        feature : 'labels',
                                        checked : false
                                    },
                                    {
                                        text    : 'Project lines',
                                        feature : 'projectLines',
                                        checked : false
                                    },
                                    {
                                        text    : 'Highlight non-working time',
                                        feature : 'nonWorkingTime',
                                        checked : false
                                    },
                                    {
                                        text    : 'Enable cell editing',
                                        feature : 'cellEdit',
                                        checked : false
                                    },
                                    {
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
                                    },
                                    {
                                        text    : 'Hide schedule',
                                        cls     : 'b-separator',
                                        subGrid : 'normal',
                                        checked : false
                                    }
                                ]
                            }
                        },
                        {
                            type     : 'button',
                            text     : 'Import Master Schedule',
                            color    : 'b-blue',
                            ref      : 'importMasterSchedule',
                            icon     : 'b-fa-file-import',
                            onAction : 'up.onImportMasterSchedule'
                        },
                        // {
                        //     type       : 'button',
                        //     color      : 'b-blue',
                        //     ref        : 'settingsButton',
                        //     icon       : 'b-fa b-fa-cogs',
                        //     text       : 'Settings',
                        //     tooltip    : 'Adjust settings',
                        //     toggleable : true,
                        //     menu       : {
                        //         type        : 'popup',
                        //         anchor      : true,
                        //         cls         : 'settings-menu',
                        //         layoutStyle : {
                        //             flexDirection : 'column'
                        //         },
                        //         onBeforeShow : 'up.onSettingsShow',

                        //         items : [
                        //             {
                        //                 type      : 'slider',
                        //                 ref       : 'rowHeight',
                        //                 text      : 'Row height',
                        //                 width     : '12em',
                        //                 showValue : true,
                        //                 min       : 30,
                        //                 max       : 70,
                        //                 onInput   : 'up.onSettingsRowHeightChange'
                        //             },
                        //             {
                        //                 type      : 'slider',
                        //                 ref       : 'barMargin',
                        //                 text      : 'Bar margin',
                        //                 width     : '12em',
                        //                 showValue : true,
                        //                 min       : 0,
                        //                 max       : 10,
                        //                 onInput   : 'up.onSettingsMarginChange'
                        //             }
                        //         ]
                        //     }
                        // },
                        {
                            type       : 'button',
                            color      : 'b-blue',
                            ref        : 'saveDataButton',
                            icon       : 'b-fa b-fa-save',
                            text       : 'Save Changes',
                            onAction : 'up.onSaveClick'
                        },
                        {
                            type     : 'button',
                            text     : 'Export Schedule',
                            color    : 'b-blue',
                            ref      : 'excelExportBtn',
                            icon     : 'b-fa-file-export',
                            onAction : 'up.onExportclick'
                        },
                        {
                            type     : 'button',
                            text     : 'Import Schedule',
                            color    : 'b-blue',
                            ref      : 'excelImportBtn',
                            icon     : 'b-fa-file-import',
                            onAction : 'up.onImportclick'
                        },
                        {
                            type     : 'button',
                            text     : 'Set Original Dates',
                            color    : 'b-blue',
                            ref      : 'editOriginalDate',
                            icon     : 'b-fa-file-export',
                            onAction : 'up.onEditOriginalDate'
                        },
                        // {
                        //     type       : 'button',
                        //     color      : 'b-blue',
                        //     ref        : 'criticalPathsButton',
                        //     icon       : 'b-fa b-fa-fire',
                        //     text       : 'Critical paths',
                        //     tooltip    : 'Highlight critical paths',
                        //     toggleable : true,
                        //     onAction   : 'up.onCriticalPathsClick'
                        // },
                        
                    ]
                },
                // {
                //     type      : 'datefield',
                //     ref       : 'startDateField',
                //     label     : 'Project start',
                //     // required  : true, (done on load)
                //     flex      : '1 2 17em',
                //     listeners : {
                //         change : 'up.onStartDateChange'
                //     }
                // },
            ]
        };
    }

    updateUndoRedoButtons() {
        const
            { stm }              = this.gantt.project,
            { undoBtn, redoBtn } = this.widgetMap,
            redoCount            = stm.length - stm.position;

        undoBtn.badge = stm.position || '';
        redoBtn.badge = redoCount || '';

        undoBtn.disabled = !stm.canUndo;
        redoBtn.disabled = !stm.canRedo;
    }

    onEditOriginalDate(){
        this.gantt.callGanttComponent.openOriginDateModal()
    }

    updateStartDateField() {
        const startDateField = this.widgetMap.startDateField;

        startDateField.value = this.gantt.project.startDate;

        // This handler is called on project.load/propagationComplete, so now we have the
        // initial start date. Prior to this time, the empty (default) value would be
        // flagged as invalid.
        startDateField.required = true;
    }

    // region controller methods

    async onAddTaskClick() {

        const
            { gantt } = this,
            added = gantt.taskStore.rootNode.children[0].appendChild({ name : 'New task', duration : 1, startDate: gantt.taskStore.rootNode.children[0].startDate, endDate: gantt.taskStore.rootNode.children[0].startDate, predecessorName: '' });
            let see = gantt.taskStore;
            console.log('see ',JSON.parse(JSON.stringify(see)));
        // run propagation to calculate new task fields
        await gantt.project.propagate();

        // scroll to the added task
        await gantt.scrollRowIntoView(added);

        gantt.features.cellEdit.startEditing({
            record : added,
            field  : 'name'
        });
    }

    onEditTaskClick() {
        const { gantt } = this;

        if (gantt.selectedRecord) {
            gantt.editTask(gantt.selectedRecord);
        }
        else {
            // bryntum.gantt.Toast.show('First select the task you want to edit');
            this.gantt.callGanttComponent.showToastMessage('First select the task you want to edit');
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
            leftMargin  : 50,
            rightMargin : 50
        });
    }

    onShiftPreviousClick() {
        this.gantt.shiftPrevious();
    }

    onShiftNextClick() {
        this.gantt.shiftNext();
    }

    onStartDateChange({ value, oldValue }) {
        if (!oldValue) { // ignore initial set
            return;
        }

        this.gantt.startDate = bryntum.gantt.DateHelper.add(value, -1, 'week');

        this.gantt.project.setStartDate(value);
    }

    onFilterChange({ value }) {
        if (value === '') {
            this.gantt.taskStore.clearFilters();
        }
        else {
            value = value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

            this.gantt.taskStore.filter({
                filters : task => task.name && task.name.match(new RegExp(value, 'i')),
                replace : true
            });
        }
    }

    onFeaturesClick({ source : item }) {
        const { gantt } = this;

        if (item.feature) {
            const feature = gantt.features[item.feature];
            feature.disabled = !feature.disabled;
        }
        else if (item.subGrid) {
            const subGrid = gantt.subGrids[item.subGrid];
            subGrid.collapsed = !subGrid.collapsed;
        }
    }

    onFeaturesShow({ source : menu }) {
        const { gantt } = this;

        menu.items.forEach(item => {
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
            }
            else {
                item.checked = gantt.subGrids[item.subGrid].collapsed;
            }
        });
    }

    onSettingsShow({ source : menu }) {
        const { gantt } = this,
            { widgetMap } = menu;

        widgetMap.rowHeight.value = gantt.rowHeight;
        widgetMap.barMargin.value = gantt.barMargin;
        widgetMap.barMargin.max = (gantt.rowHeight / 2) - 5;
    }

    onSettingsRowHeightChange({ value }) {
        this.gantt.rowHeight = value;
        this.widgetMap.settingsButton.menu.widgetMap.barMargin.max = (value / 2) - 5;
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

    onSaveClick() {
        try {
            var data = this.gantt.data;
            var taskData = JSON.parse(this.gantt.taskStore.json);
            var taskEdit = this.gantt.taskStore;
            console.log('taskEdit ',{taskEdit});
            console.log('assignmentStore JSON ',JSON.parse(taskEdit.assignmentStore.json));
            let assignedResources = setResourceDataForApexData(JSON.parse(taskEdit.assignmentStore.json));
            console.log('assignedResources ',assignedResources);
            if (assignedResources == 'error') {
                this.gantt.callGanttComponent.showToastMessage('Can not Select more then 3 Internal or External Resources!');
                this.gantt.callGanttComponent.template.querySelector('.container').innerHTML = '';
                this.gantt.callGanttComponent.createGanttChartInitially();
            }else{
                var dependenciesData = JSON.parse(this.gantt.dependencyStore.json);
                var resourceData = JSON.parse(this.gantt.assignmentStore.json)
                let dataForApexController = convertJSONtoApexData(data, taskData, dependenciesData, resourceData);
                console.log('dataForApexController ',dataForApexController);
                this.gantt.callGanttComponent.saveChanges(dataForApexController.scheduleData,dataForApexController.taskData, dependenciesData, assignedResources);
            }
        } catch (error) {
            console.log('Error-->' + error + ' message-->' + error.message);
            this.gantt.callGanttComponent.showToastMessage('Dates cannot be null or empty');
        }
    }

    onExportclick(){
        this.gantt.callGanttComponent.exportData();
    }

    onImportclick(){
        this.gantt.callGanttComponent.importtData();
    }

    onImportMasterSchedule(){
        this.gantt.callGanttComponent.openMasterSchedule()
    }
};