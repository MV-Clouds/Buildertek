import SchedulerProTaskEdit from '../../SchedulerPro/feature/TaskEdit.js';
import TaskEditor from '../widget/TaskEditor.js';
import GridFeatureManager from '../../Grid/feature/GridFeatureManager.js';

/**
 * @module Gantt/feature/TaskEdit
 */

/**
 * Feature that allows editing tasks using a {@link Gantt/widget/TaskEditor}, a popup with fields for editing task data.
 *
 * This demo shows the task edit feature, double-click child task bar to start editing:
 *
 * {@inlineexample Gantt/feature/TaskEdit.js}
 *
 * ## Customizing tabs and their widgets
 *
 * To customize tabs you can:
 *
 * * Reconfigure built in tabs by providing override configs in the {@link #config-items} config.
 * * Remove existing tabs or add your own in the {@link #config-items} config.
 * * Advanced: Reconfigure the whole editor widget using {@link #config-editorConfig} or replace the whole editor
 *   using {@link #config-editorClass}.
 *
 * This example shows a custom Task Editor configuration. The built-in "Notes" tab is hidden, a custom "Files" tab is
 * added, the "General" tab is renamed to "Common" and "Custom" field is appended to it. Double-click on a task bar to
 * start editing:
 *
 * {@inlineexample Gantt/feature/TaskEditCustom.js}
 *
 * To add extra items to a tab you need to specify {@link Core/widget/Container#config-items} for the tab container.
 * This example shows custom widgets added to "General" tab:
 *
 * {@inlineexample Gantt/feature/TaskEditExtraItems.js}
 *
 * {@region Expand to see Default tabs and fields}
 *
 * The {@link Gantt/widget/TaskEditor Task editor} contains tabs by default. Each tab is a container with built in
 * widgets: text fields, grids, etc.
 *
 * | Tab ref           | Type                                                   | Text         | Weight | Description                                            |
 * |-------------------|--------------------------------------------------------|--------------|--------|--------------------------------------------------------|
 * | `generalTab`      | {@link SchedulerPro/widget/taskeditor/GeneralTab}      | General      | 100    | Name, start/end dates, duration, percent done, effort. |
 * | `predecessorsTab` | {@link SchedulerPro/widget/taskeditor/PredecessorsTab} | Predecessors | 200    | Grid with incoming dependencies                        |
 * | `successorsTab`   | {@link SchedulerPro/widget/taskeditor/SuccessorsTab}   | Successors   | 300    | Grid with outgoing dependencies                        |
 * | `resourcesTab`    | {@link SchedulerPro/widget/taskeditor/ResourcesTab}    | Resources    | 400    | Grid with assigned resources                           |
 * | `advancedTab`     | {@link SchedulerPro/widget/taskeditor/AdvancedTab}     | Advanced     | 500    | Assigned calendar, scheduling mode, constraints, etc.  |
 * | `notesTab`        | {@link SchedulerPro/widget/taskeditor/NotesTab}        | Notes        | 600    | Text area to add notes to the selected task            |
 *
 * ### General tab
 *
 * General tab contains widgets for basic configurations
 *
 * | Widget ref    | Type                                       | Text       | Weight | Description                                                |
 * |---------------|--------------------------------------------|------------|--------|------------------------------------------------------------|
 * | `name`        | {@link Core/widget/TextField}              | Name       | 100    | Task name                                                  |
 * | `percentDone` | {@link Core/widget/NumberField}            | % Complete | 200    | Shows what part of task is done already in percentage      |
 * | `effort`      | {@link SchedulerPro/widget/EffortField}    | Effort     | 300    | Amount of working time required to complete the whole task |
 * | `divider`     | {@link Core/widget/Widget}                 |            | 400    | Visual splitter between 2 groups of fields                 |
 * | `startDate`   | {@link SchedulerPro/widget/StartDateField} | Start      | 500    | Shows when the task begins                                 |
 * | `endDate`     | {@link SchedulerPro/widget/EndDateField}   | Finish     | 600    | Shows when the task ends                                   |
 * | `duration`    | {@link Core/widget/DurationField}          | Duration   | 700    | Shows how long the task is                                 |
 *
 * ### Predecessors tab
 *
 * Predecessors tab contains a grid with incoming dependencies and controls to remove/add dependencies
 *
 * | Widget ref | Type                        | Weight | Description                                                      |
 * |------------|-----------------------------|--------|------------------------------------------------------------------|
 * | `grid`     | {@link Grid/view/Grid}      | 100    | Predecessors task name, dependency type and lag                  |
 * | `toolbar`  | {@link Core/widget/Toolbar} | 200    | Control buttons                                                  |
 * | \>`add`    | {@link Core/widget/Button}  | 210    | Adds a new predecessor, select task using the name column editor |
 * | \>`remove` | {@link Core/widget/Button}  | 220    | Removes selected incoming dependency                             |
 *
 * \> - nested items
 *
 * ### Successors tab
 *
 * Successors tab contains a grid with outgoing dependencies and controls to remove/add dependencies
 *
 * | Widget ref | Type                        | Weight | Description                                                    |
 * |------------|-----------------------------|--------|----------------------------------------------------------------|
 * | `grid`     | {@link Grid/view/Grid}      | 100    | Successors task name, dependency type and lag                  |
 * | `toolbar`  | {@link Core/widget/Toolbar} | 200    | Control buttons                                                |
 * | \>`add`    | {@link Core/widget/Button}  | 210    | Adds a new successor, select task using the name column editor |
 * | \>`remove` | {@link Core/widget/Button}  | 220    | Removes selected outgoing dependency                           |
 *
 * \> - nested items
 *
 * ### Resources tab
 *
 * Resources tab contains a grid with assignments
 *
 * | Widget ref | Type                        | Weight | Description                                                                                                            |
 * |------------|-----------------------------|--------|------------------------------------------------------------------------------------------------------------------------|
 * | `grid`     | {@link Grid/view/Grid}      | 100    | Assignments resource name and units (100 means that the assigned resource spends 100% of its working time to the task) |
 * | `toolbar`  | {@link Core/widget/Toolbar} | 200    | Shows control buttons                                                                                                  |
 * | \>`add`    | {@link Core/widget/Button}  | 210    | Adds a dummy assignment, select resource using the name column editor                                                  |
 * | \>`remove` | {@link Core/widget/Button}  | 220    | Removes selected assignment                                                                                            |
 *
 * \> - nested items
 *
 * ### Advanced tab
 *
 * Advanced tab contains additional task scheduling options
 *
 * | Widget ref                    | Type                                             | Weight | Description                                                                                                                  |
 * |-------------------------------|--------------------------------------------------|--------|------------------------------------------------------------------------------------------------------------------------------|
 * | `calendarField`               | {@link Core/widget/Combo}                        | 100    | Shows a list of available calendars for this task                                                                            |
 * | `manuallyScheduledField`      | {@link Core/widget/Checkbox}                     | 200    | If checked, the task is not considered in scheduling                                                                         |
 * | `schedulingModeField`         | {@link SchedulerPro/widget/SchedulingModePicker} | 300    | Shows a list of available scheduling modes for this task                                                                     |
 * | `effortDrivenField`           | {@link Core/widget/Checkbox}                     | 400    | If checked, the effort of the task is kept intact, and the duration is updated. Works when scheduling mode is "Fixed Units". |
 * | `divider`                     | {@link Core/widget/Widget}                       | 500    | Visual splitter between 2 groups of fields                                                                                   |
 * | `constraintTypeField`         | {@link SchedulerPro/widget/ConstraintTypePicker} | 600    | Shows a list of available constraints for this task                                                                          |
 * | `constraintDateField`         | {@link Core/widget/DateField}                    | 700    | Shows a date for the selected constraint type                                                                                |
 * | `rollupField`                 | {@link Core/widget/Checkbox}                     | 800    | If checked, shows a bar below the parent task. Works when the "Rollup" feature is enabled.                                   |
 * | `inactiveField`               | {@link Core/widget/Checkbox}                     | 900    | Allows to inactivate the task so it won't take part in the scheduling process.                                               |
 * | `ignoreResourceCalendarField` | {@link Core/widget/Checkbox}                     | 1000   | If checked the task ignores the assigned resource calendars when scheduling                                                  |
 *
 * ### Notes tab
 *
 * Notes tab contains a text area to show notes
 *
 * | Field ref   | Type                              | Weight | Description                                     |
 * |-------------|-----------------------------------|--------|-------------------------------------------------|
 * | `noteField` | {@link Core/widget/TextAreaField} | 100    | Shows a text area to add text notes to the task |
 *
 * {@endregion}
 *
 * ## Removing a built in item
 *
 * To remove a built in tab or widget, specify its `ref` as `false` in the {@link #config-items} config:
 *
 * ```javascript
 * const gantt = new Gantt({
 *     features : {
 *         taskEdit : {
 *             items : {
 *                 generalTab      : {
 *                     items : {
 *                         // Remove "% Complete","Effort", and the divider in the "General" tab
 *                         percentDone : false,
 *                         effort      : false,
 *                         divider     : false
 *                     }
 *                 },
 *                 // Remove all tabs except the "General" tab
 *                 notesTab        : false,
 *                 predecessorsTab : false,
 *                 successorsTab   : false,
 *                 resourcesTab    : false,
 *                 advancedTab     : false
 *             }
 *         }
 *     }
 * })
 * ```
 *
 * The built in buttons are:
 *
 * | Widget ref     | Type                       | Weight | Description                             |
 * |----------------|----------------------------|--------|-----------------------------------------|
 * | `saveButton`   | {@link Core/widget/Button} | 100    | Save event button on the bbar           |
 * | `deleteButton` | {@link Core/widget/Button} | 200    | Delete event button on the bbar         |
 * | `cancelButton` | {@link Core/widget/Button} | 300    | Cancel event editing button on the bbar |
 *
 * Bottom buttons may be hidden using `bbar` config passed to `editorConfig`:
 *
* ```javascript
 * const gantt = new Gantt({
 *     features : {
 *         taskEdit : {
 *             editorConfig : {
 *                 bbar : {
 *                     items : {
 *                         deleteButton : false
 *                     }
 *                 }
 *             }
 *         }
 *     }
 * })
 * ```
 *
 * ## Customizing a built in item
 *
 * To customize a built in tab or field, use its `ref` as the key in the {@link #config-items} config and specify the configs you want
 * to change (they will be merged with the tabs or fields default configs correspondingly):
 *
 * ```javascript
 * const gantt = new Gantt({
 *     features : {
 *         taskEdit : {
 *             items : {
 *                 generalTab      : {
 *                     // Rename "General" tab
 *                     title : 'Main',
 *                     items : {
 *                         // Rename "% Complete" field
 *                         percentDone : {
 *                             label : 'Status'
 *                         }
 *                     }
 *                 }
 *             }
 *         }
 *     }
 * })
 * ```
 *
 * ## Adding a custom item
 *
 * To add a custom tab or field, add an entry to the {@link #config-items} config. When you add a field,
 * the `name` property links the input field to a field in the loaded task record:
 *
 * ```javascript
 * const gantt = new Gantt({
 *     features : {
 *         taskEdit : {
 *             items : {
 *                 generalTab : {
 *                     items : {
 *                         // Add new field to the last position
 *                         newGeneralField : {
 *                             type   : 'textfield',
 *                             weight : 710,
 *                             label  : 'New field in General Tab',
 *                             // Name of the field matches data field name, so value is loaded/saved automatically
 *                             name   : 'custom'
 *                         }
 *                     }
 *                 },
 *                 // Add a custom tab to the first position
 *                 newTab     : {
 *                     // Tab is a FormTab by default
 *                     title  : 'New tab',
 *                     weight : 90,
 *                     items  : {
 *                         newTabField : {
 *                             type   : 'textfield',
 *                             weight : 710,
 *                             label  : 'New field in New Tab',
 *                             // Name of the field matches data field name, so value is loaded/saved automatically.
 *                             // In this case it is equal to the Task "name" field.
 *                             name   : 'name'
 *                         }
 *                     }
 *                 }
 *             }
 *         }
 *     }
 * })
 * ```
 *
 * To turn off the Task Editor just simple disable the feature.
 *
 * ```javascript
 * const gantt = new Gantt({
 *     features : {
 *         taskEdit : false
 *     }
 * })
 * ```
 *
 * For more info on customizing the Task Editor, please see Guides/Customization/Customize task editor
 *
 * @extends SchedulerPro/feature/TaskEdit
 * @demo Gantt/taskeditor
 * @classtype taskEdit
 * @feature
 *
 * @typings SchedulerPro/feature/TaskEdit -> SchedulerPro/feature/SchedulerProTaskEdit
 */
export default class TaskEdit extends SchedulerProTaskEdit {

    static get $name() {
        return 'TaskEdit';
    }

    static get defaultConfig() {
        return {
            /**
             * The event that shall trigger showing the editor. Set to `` or null to disable editing of existing events.
             * @config {String|null}
             * @default
             * @category Editor
             */
            triggerEvent : 'taskdblclick',

            saveAndCloseOnEnter : true,

            /**
             * Class to use as the editor. By default it uses {@link Gantt.widget.TaskEditor}
             * @config {Core.widget.Widget}
             * @typings {typeof Widget}
             * @category Editor
             */
            editorClass : TaskEditor
        };
    }

    static get pluginConfig() {
        return {
            chain  : ['populateTaskMenu', 'onTaskEnterKey'],
            assign : ['editTask']
        };
    }

    /**
     * Shows a {@link Gantt/widget/TaskEditor} to edit the passed task. This function is exposed on
     * the Gantt instance and can be called as `gantt.editTask()`.
     * @param {Gantt.model.TaskModel} taskRecord Task to edit
     * @param {HTMLElement} [element] The task element
     * @returns {Promise} Promise which resolves after the editor is shown
     * @on-owner
     * @async
     */
    editTask(taskRecord, element) {
        return this.editEvent(taskRecord, null, element);
    }

    onActivateEditor({ taskRecord, taskElement }) {
        this.editTask(taskRecord, taskElement);
    }

    getElementFromTaskRecord(taskRecord) {
        return this.client.getElementFromTaskRecord(taskRecord);
    }

    onTaskEnterKey({ taskRecord }) {
        this.editTask(taskRecord);
    }

    //region Context menu

    populateTaskMenu({ taskRecord, selection, items }) {
        // Task without project is transient record in a display store and not meant to be manipulated
        if (!this.client.readOnly && selection.length <= 1 && taskRecord.project) {
            items.editTask = {
                text        : 'L{Gantt.Edit}',
                localeClass : this.client,
                cls         : 'b-separator',
                icon        : 'b-icon b-icon-edit',
                weight      : 100,
                disabled    : this.disabled || taskRecord.readOnly,
                onItem      : () => this.editTask(taskRecord)
            };
        }
    }

    //endregion

    onEventEnterKey({ taskRecord, target }) {
        this.editTask(taskRecord);
    }

    scrollTaskIntoView(taskRecord) {
        return this.scrollEventIntoView(taskRecord);
    }

    scrollEventIntoView(eventRecord) {
        return this.client.scrollTaskIntoView(eventRecord);
    }
}

GridFeatureManager.registerFeature(TaskEdit, true, 'Gantt');
