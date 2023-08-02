/*!
 *
 * Bryntum Gantt 4.2.4 (TRIAL VERSION)
 *
 * Copyright(c) 2021 Bryntum AB
 * https://bryntum.com/contact
 * https://bryntum.com/license
 *
 */
declare module '@bryntum/gantt/gantt.umd.js' {

    type DomConfig = {
        tag: string
        class: string|object
        className: string|object
        style: string|object
        dataset: object
        children: DomConfig[]|DomConfig|string
        html: string
    }

    type PanelHeader = {
        cls: string|object
        dock: string
        title: string
        titleAlign: string
    }

    type Breakpoint = {
        name: string
        configs: object
        callback: Function
    }

    export abstract class Base {
        config: object
        isDestroyed: boolean
        isDestroying: boolean
        constructor(args?: object);
        static initClass(): void;
        static isOfTypeName(type: string): boolean;
        static mixin(mixins: Function): Function;
        callback(fn: string|Function, thisObject: object, args: object[]): void;
        construct(args?: object): void;
        destroy(): void;
        detachListeners(name: string): void;
        doDestroy(): void;
        resolveCallback(handler: string|Function, thisObj: object, enforceCallability?: boolean): object;
        setConfig(config: object): void;
    }

    export class GlobalEventsSingleton {
        onBeforeDestroy: Function
        onCatchAll: Function
        onDestroy: Function
        onTheme: Function
        addListener(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        hasListener(eventName: string): boolean;
        on(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        relayAll(through: Events, prefix: string, transformCase?: boolean): void;
        removeAllListeners(): void;
        removeListener(config: object, thisObj: object): void;
        resumeEvents(): void;
        suspendEvents(queue?: boolean): void;
        trigger(eventName: string, param?: object): boolean|Promise<any>;
        un(config: object, thisObj?: object): void;
    }

    export const GlobalEvents : GlobalEventsSingleton

    type WidgetTagConfig = {
        faPath: string
        stylesheet: string
    }

    export class WidgetTag {
        widget: Widget
        constructor(config?: Partial<WidgetTagConfig>);
        destroy(): void;
    }

    type AjaxStoreConfig = {
        allowNoId: boolean
        autoCommit: boolean
        autoLoad: boolean
        autoTree: boolean
        bubbleEvents: object
        chainedFields: string[]
        chainedFilterFn: Function
        createUrl: string
        data: object[]|Model[]|Partial<ModelConfig>[]
        deleteUrl: string
        doRelayToMaster: string[]
        dontRelayToMaster: string
        fetchOptions: object
        fields: string[]|object[]|DataField[]|Partial<DataFieldConfig>[]
        filterParamName: string
        filters: object|object[]
        groupers: object[]
        headers: object
        httpMethods: object
        id: string|number
        keepUncommittedChanges: boolean
        listeners: object
        masterStore: Store
        modelClass: typeof Model
        pageParamName: string
        pageSize: number
        pageSizeParamName: string
        pageStartParamName: string
        params: object
        parentIdParamName: string
        readUrl: string
        reapplyFilterOnAdd: boolean
        reapplyFilterOnUpdate: boolean
        reapplySortersOnAdd: boolean
        responseDataProperty: string
        responseSuccessProperty: string
        responseTotalProperty: string
        restfulFilter: boolean
        sendAsFormData: boolean
        sortParamName: string
        sorters: object[]|string[]
        stm: StateTrackingManager
        storage: Collection|object|Partial<CollectionConfig>
        syncDataOnLoad: boolean|object
        transformFlatData: boolean
        tree: boolean
        updateUrl: string
        useLocaleSort: boolean|string|object
        useRawData: boolean|object
        useRestfulMethods: boolean
        writeAllFields: boolean
        onAfterRequest: Function
        onBeforeLoad: Function
        onBeforeLoadChildren: Function
        onBeforeLoadPage: Function
        onBeforeRequest: Function
        onCommitAdded: Function
        onCommitModified: Function
        onCommitRemoved: Function
        onException: Function
        onLoad: Function
        onLoadChildren: Function
        onLoadChildrenStart: Function
        onLoadStart: Function
    }

    export class AjaxStore extends Store {
        allCount: number
        isCommitting: boolean
        isLoading: boolean
        isPaged: boolean
        lastPage: number
        params: object
        onAfterRequest: Function
        onBeforeLoad: Function
        onBeforeLoadChildren: Function
        onBeforeLoadPage: Function
        onBeforeRequest: Function
        onCommitAdded: Function
        onCommitModified: Function
        onCommitRemoved: Function
        onException: Function
        onLoad: Function
        onLoadChildren: Function
        onLoadChildrenStart: Function
        onLoadStart: Function
        constructor(config?: Partial<AjaxStoreConfig>);
        commit(): Promise<any>;
        encodeFilterParams(filters: CollectionFilter[]): void;
        encodeSorterParams(sorters: object[]): void;
        load(params?: object): Promise<any>;
        loadChildren(parentRecord: Model): Promise<any>;
        loadPage(page: number, params: object): Promise<any>;
        nextPage(): Promise<any>;
        previousPage(): Promise<any>;
    }

    export class Duration {
        magnitude: number
        milliseconds: number
        unit: string
        isEqual(value: Duration): boolean;
    }

    type ModelConfig = {
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        id: string|number
        parentId: string|number|null
        parentIndex: number
    }

    export class Model implements TreeNode, ModelStm {
        static autoExposeFields: boolean
        static childrenField: string
        static convertEmptyParentToLeaf: boolean|object
        static defaults: object
        static idField: string
        allChildren: Model[]
        allFields: DataField[]
        childLevel: number
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        descendantCount: number
        fieldMap: object
        fieldNames: string[]
        fields: DataField[]
        firstChild: Model
        firstStore: Store
        hasGeneratedId: boolean
        id: string|number
        internalId: number
        isBatchUpdating: boolean
        isCommitting: boolean
        isCreating: boolean
        isLeaf: boolean
        isLoaded: boolean
        isModified: boolean
        isParent: boolean
        isPersistable: boolean
        isPhantom: boolean
        isValid: boolean
        json: string
        lastChild: Model
        modificationData: object
        modificationDataToWrite: object
        modifications: object
        parent: Model
        parentId: number|string|null
        parentIndex: number
        previousSiblingsTotalCount: number
        stm: StateTrackingManager
        visibleDescendantCount: number
        constructor(data?: object, store?: Store, meta?: object);
        static addField(fieldDef: string|object): void;
        static asId(model: Model|string|number): string|number;
        static getFieldDefinition(fieldName: string): DataField;
        static processField(fieldName: string, value: any): any;
        static removeField(fieldName: string): void;
        ancestorsExpanded(store?: Store): boolean;
        appendChild(childRecord: Model|Model[], silent?: boolean): Model|Model[];
        beginBatch(): void;
        bubble(fn: Function, skipSelf?: boolean): void;
        bubbleWhile(fn: Function, skipSelf?: boolean): boolean;
        cancelBatch(): void;
        clearChanges(): void;
        contains(childOrId: Model|string|number): boolean;
        copy(newId?: number|string|object, deep?: boolean): Model;
        endBatch(silent?: boolean): void;
        equals(other: Model): boolean;
        generateId(): void;
        get(fieldName: string): any;
        getData(fieldName: string): any;
        getDataSource(fieldName: string): string;
        getDescendantCount(onlyVisible?: boolean, store?: Store): number;
        hasBatchedChange(fieldName: string): boolean;
        insertChild(childRecord: Model|Model[], before?: Model, silent?: boolean): Model|Model[];
        isExpanded(store: Store): boolean;
        isFieldModified(fieldName: string): boolean;
        remove(silent?: boolean): void;
        removeChild(childRecords: Model|Model[], isMove?: boolean, silent?: boolean): void;
        revertChanges(): void;
        set(field: string|object, value: any, silent?: boolean): void;
        toJSON(): object;
        toString(): string;
        traverse(fn: Function, skipSelf?: boolean, includeFilteredOutRecords?: boolean): void;
        traverseBefore(fn: Function, skipSelf?: boolean, includeFilteredOutRecords?: boolean): void;
        traverseWhile(fn: Function, skipSelf?: boolean, includeFilteredOutRecords?: boolean): boolean;
    }

    type StoreConfig = {
        allowNoId: boolean
        autoCommit: boolean
        autoTree: boolean
        bubbleEvents: object
        chainedFields: string[]
        chainedFilterFn: Function
        data: object[]|Model[]|Partial<ModelConfig>[]
        doRelayToMaster: string[]
        dontRelayToMaster: string
        fields: string[]|object[]|DataField[]|Partial<DataFieldConfig>[]
        filters: object|object[]
        groupers: object[]
        id: string|number
        keepUncommittedChanges: boolean
        listeners: object
        masterStore: Store
        modelClass: typeof Model
        reapplyFilterOnAdd: boolean
        reapplyFilterOnUpdate: boolean
        reapplySortersOnAdd: boolean
        sorters: object[]|string[]
        stm: StateTrackingManager
        storage: Collection|object|Partial<CollectionConfig>
        syncDataOnLoad: boolean|object
        transformFlatData: boolean
        tree: boolean
        useLocaleSort: boolean|string|object
        useRawData: boolean|object
        onAdd: Function
        onAddConfirmed: Function
        onBeforeAdd: Function
        onBeforeCommit: Function
        onBeforeDestroy: Function
        onBeforeRemove: Function
        onBeforeSort: Function
        onBeforeUpdate: Function
        onCatchAll: Function
        onChange: Function
        onCommit: Function
        onDestroy: Function
        onFilter: Function
        onGroup: Function
        onIdChange: Function
        onMove: Function
        onRefresh: Function
        onRemove: Function
        onRemoveAll: Function
        onRootChange: Function
        onSort: Function
        onUpdate: Function
    }

    export class Store extends Base implements Events, StoreFilter, StoreCRUD, StoreSum, StoreSearch, StoreSort, StoreGroup, StoreChained, StoreState, StoreTree, StoreStm, StoreSync {
        static stores: Store[]
        allCount: number
        allRecords: Model[]
        autoCommit: boolean
        changes: object
        count: number
        data: object[]
        filters: Collection
        first: Model
        formattedJSON: string
        groupers: object[]
        isChained: boolean
        isFiltered: boolean
        isGrouped: boolean
        isSorted: boolean
        isTree: boolean
        json: string
        last: Model
        leaves: Model[]
        modelClass: typeof Model
        originalCount: number
        records: Model[]
        rootNode: Model
        sorters: object[]
        onAdd: Function
        onAddConfirmed: Function
        onBeforeAdd: Function
        onBeforeCommit: Function
        onBeforeDestroy: Function
        onBeforeRemove: Function
        onBeforeSort: Function
        onBeforeUpdate: Function
        onCatchAll: Function
        onChange: Function
        onCommit: Function
        onDestroy: Function
        onFilter: Function
        onGroup: Function
        onIdChange: Function
        onMove: Function
        onRefresh: Function
        onRemove: Function
        onRemoveAll: Function
        onRootChange: Function
        onSort: Function
        onUpdate: Function
        constructor(config?: Partial<StoreConfig>);
        static getStore(id: string|number|object[]): Store;
        add(records: Model|Model[]|object|object[]|Partial<ModelConfig>|Partial<ModelConfig>[], silent?: boolean): Model[];
        addFilter(newFilters: object|Function, silent?: boolean): CollectionFilter;
        addListener(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        addSorter(field: string|object[]|object|Function, ascending?: boolean): void;
        applyChangesFromStore(otherStore: Store): void;
        average(field: string, records: Model[]): number;
        beginBatch(): void;
        chain(chainedFilterFn: Function, chainedFields: string[], config: object): Store;
        clearFilters(): void;
        clearGroupers(): void;
        clearSorters(): void;
        commit(silent?: boolean): object;
        createRecord(data: object, skipExpose?: boolean): void;
        createSorterFn(sorters: object[]): Function;
        endBatch(): void;
        fillFromMaster(): void;
        filter(newFilters: object|object[]|Function): void;
        filterBy(fn: Function): void;
        find(fn: Function, searchAllRecords?: boolean): Model;
        findByField(field: string, value: any): any;
        findRecord(fieldName: string, value: any, searchAllRecords?: boolean): Model;
        forEach(fn: Function, thisObj?: object, options?: object|boolean): void;
        getAt(index: number): Model;
        getById(id: Model|string|number): Model;
        getByInternalId(internalId: number): Model;
        getChildren(parent: Model): Model[];
        getCount(countProcessed?: boolean): number;
        getDistinctValues(field: string): any[];
        getGroupRecords(groupValue: any): Model[];
        getGroupTitles(): string[];
        getNext(recordOrId: Model|string|number, wrap?: boolean, skipSpecialRows?: boolean): Model;
        getPrev(recordOrId: Model|string|number, wrap?: boolean, skipSpecialRows?: boolean): Model;
        getRange(start?: number, end?: number): Model[];
        getValueCount(field: string, value: any): number;
        group(field: string|object, ascending?: boolean, add?: boolean, performSort?: boolean, silent?: boolean): void;
        groupSum(groupValue: any, field: string): number;
        hasListener(eventName: string): boolean;
        includes(recordOrId: Model|string|number): boolean;
        indexOf(recordOrId: Model|string|number, visibleRecords?: boolean): number;
        insert(index: number, records: Model|Model[]|object|object[]|Partial<ModelConfig>|Partial<ModelConfig>[], silent?: boolean): Model[];
        isAvailable(recordOrId: Model|string|number): boolean;
        isRecordInGroup(record: Model, groupValue: any): boolean;
        loadChildren(parentRecord: Model): Promise<any>;
        makeChained(chainedFilterFn: Function, chainedFields: string[], config: object): Store;
        map(fn: Function): any[];
        max(field: string, records: Model[]): number|Date;
        min(field: string, records: Model[]): number|Date;
        move(records: Model|Model[], beforeRecord: Model): void;
        on(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        onDataChange(event: object): void;
        query(fn: Function, searchAllRecords?: boolean): Model[];
        reduce(fn: Function, initialValue: any): any;
        relayAll(through: Events, prefix: string, transformCase?: boolean): void;
        remove(records: string|string[]|number|number[]|Model|Model[], silent?: boolean): Model[];
        removeAll(silent?: boolean): boolean;
        removeAllListeners(): void;
        removeFilter(idOrInstance: string|CollectionFilter, silent?: boolean): CollectionFilter;
        removeListener(config: object, thisObj: object): void;
        removeSorter(field: string|Function): void;
        resumeAutoCommit(): void;
        resumeEvents(): void;
        revertChanges(): void;
        search(find: string, fields: object[]): object[];
        some(fn: Function, searchAllRecords?: boolean): boolean;
        sort(field: string|object[]|object|Function, ascending?: boolean, add?: boolean, silent?: boolean): void;
        sum(field: string, records: Model[]): number;
        suspendAutoCommit(): void;
        suspendEvents(queue?: boolean): void;
        toJSON(): object[];
        toggleCollapse(idOrRecord: string|number|Model, collapse?: boolean): Promise<any>;
        traverse(fn: Function, topNode?: Model, skipTopNode?: boolean, options?: object|boolean): void;
        traverseWhile(fn: Function, topNode?: Model, skipTopNode?: boolean): void;
        trigger(eventName: string, param?: object): boolean|Promise<any>;
        un(config: object, thisObj?: object): void;
    }

    type BooleanDataFieldConfig = {
        alwaysWrite: boolean
        column: string|object
        compare: Function
        dataSource: string
        defaultValue: any
        internal: boolean
        label: string
        name: string
        nullText: string
        nullValue: boolean
        nullable: boolean
        persist: boolean
        readOnly: boolean
    }

    export class BooleanDataField extends DataField {
        constructor(config?: Partial<BooleanDataFieldConfig>);
    }

    type DataFieldConfig = {
        alwaysWrite: boolean
        column: string|object
        compare: Function
        dataSource: string
        defaultValue: any
        internal: boolean
        label: string
        name: string
        nullText: string
        nullValue: any
        nullable: boolean
        persist: boolean
        readOnly: boolean
    }

    export class DataField extends Base {
        constructor(config?: Partial<DataFieldConfig>);
        convert(value: any): any;
        isEqual(first: any, second: any): boolean;
        print(value: any): string;
        printValue(value: any): string;
        serialize(value: any, record: Model): any;
    }

    type DateDataFieldConfig = {
        alwaysWrite: boolean
        column: string|object
        compare: Function
        dataSource: string
        dateFormat: string
        defaultValue: any
        format: string
        internal: boolean
        label: string
        name: string
        nullText: string
        nullValue: any
        nullable: boolean
        persist: boolean
        readOnly: boolean
    }

    export class DateDataField extends DataField {
        constructor(config?: Partial<DateDataFieldConfig>);
    }

    type IntegerDataFieldConfig = {
        alwaysWrite: boolean
        column: string|object
        compare: Function
        dataSource: string
        defaultValue: any
        internal: boolean
        label: string
        name: string
        nullText: string
        nullValue: number
        nullable: boolean
        persist: boolean
        readOnly: boolean
        rounding: string
    }

    export class IntegerDataField extends DataField {
        constructor(config?: Partial<IntegerDataFieldConfig>);
    }

    type NumberDataFieldConfig = {
        alwaysWrite: boolean
        column: string|object
        compare: Function
        dataSource: string
        defaultValue: any
        internal: boolean
        label: string
        name: string
        nullText: string
        nullValue: number
        nullable: boolean
        persist: boolean
        precision: number
        readOnly: boolean
    }

    export class NumberDataField extends DataField {
        constructor(config?: Partial<NumberDataFieldConfig>);
    }

    type StringDataFieldConfig = {
        alwaysWrite: boolean
        column: string|object
        compare: Function
        dataSource: string
        defaultValue: any
        internal: boolean
        label: string
        name: string
        nullText: string
        nullValue: string
        nullable: boolean
        persist: boolean
        readOnly: boolean
    }

    export class StringDataField extends DataField {
        constructor(config?: Partial<StringDataFieldConfig>);
    }

    type StoreCRUDConfig = {
        autoCommit: boolean
        onAdd: Function
        onBeforeAdd: Function
        onBeforeCommit: Function
        onBeforeRemove: Function
        onCommit: Function
        onRemove: Function
        onRemoveAll: Function
    }

    export class StoreCRUD {
        autoCommit: boolean
        changes: object
        onAdd: Function
        onBeforeAdd: Function
        onBeforeCommit: Function
        onBeforeRemove: Function
        onCommit: Function
        onRemove: Function
        onRemoveAll: Function
        constructor(config?: Partial<StoreCRUDConfig>);
        add(records: Model|Model[]|object|object[]|Partial<ModelConfig>|Partial<ModelConfig>[], silent?: boolean): Model[];
        applyChangesFromStore(otherStore: Store): void;
        commit(silent?: boolean): object;
        insert(index: number, records: Model|Model[]|object|object[]|Partial<ModelConfig>|Partial<ModelConfig>[], silent?: boolean): Model[];
        move(records: Model|Model[], beforeRecord: Model): void;
        remove(records: string|string[]|number|number[]|Model|Model[], silent?: boolean): Model[];
        removeAll(silent?: boolean): boolean;
        resumeAutoCommit(): void;
        revertChanges(): void;
        suspendAutoCommit(): void;
    }

    type StoreChainedConfig = {
        chainedFields: string[]
        chainedFilterFn: Function
        doRelayToMaster: string[]
        dontRelayToMaster: string
        keepUncommittedChanges: boolean
        masterStore: Store
    }

    export class StoreChained {
        isChained: boolean
        constructor(config?: Partial<StoreChainedConfig>);
        chain(chainedFilterFn: Function, chainedFields: string[], config: object): Store;
        fillFromMaster(): void;
        makeChained(chainedFilterFn: Function, chainedFields: string[], config: object): Store;
    }

    type StoreFilterConfig = {
        filters: object|object[]
        reapplyFilterOnAdd: boolean
        reapplyFilterOnUpdate: boolean
        onFilter: Function
    }

    export class StoreFilter {
        filters: Collection
        isFiltered: boolean
        onFilter: Function
        constructor(config?: Partial<StoreFilterConfig>);
        addFilter(newFilters: object|Function, silent?: boolean): CollectionFilter;
        clearFilters(): void;
        filter(newFilters: object|object[]|Function): void;
        filterBy(fn: Function): void;
        removeFilter(idOrInstance: string|CollectionFilter, silent?: boolean): CollectionFilter;
    }

    type StoreGroupConfig = {
        groupers: object[]
        onGroup: Function
    }

    export class StoreGroup {
        groupers: object[]
        isGrouped: boolean
        onGroup: Function
        constructor(config?: Partial<StoreGroupConfig>);
        clearGroupers(): void;
        getGroupRecords(groupValue: any): Model[];
        getGroupTitles(): string[];
        group(field: string|object, ascending?: boolean, add?: boolean, performSort?: boolean, silent?: boolean): void;
        isRecordInGroup(record: Model, groupValue: any): boolean;
    }

    type StoreProxyConfig = {
        objectify: boolean
    }

    export class StoreProxy {
        constructor(config?: Partial<StoreProxyConfig>);
    }

    export class StoreSearch {
        find(fn: Function, searchAllRecords?: boolean): Model;
        findByField(field: string, value: any): any;
        findRecord(fieldName: string, value: any, searchAllRecords?: boolean): Model;
        query(fn: Function, searchAllRecords?: boolean): Model[];
        search(find: string, fields: object[]): object[];
        some(fn: Function, searchAllRecords?: boolean): boolean;
    }

    type StoreSortConfig = {
        reapplySortersOnAdd: boolean
        sorters: object[]|string[]
        useLocaleSort: boolean|string|object
        onBeforeSort: Function
        onSort: Function
    }

    export class StoreSort {
        isSorted: boolean
        sorters: object[]
        onBeforeSort: Function
        onSort: Function
        constructor(config?: Partial<StoreSortConfig>);
        addSorter(field: string|object[]|object|Function, ascending?: boolean): void;
        clearSorters(): void;
        createSorterFn(sorters: object[]): Function;
        removeSorter(field: string|Function): void;
        sort(field: string|object[]|object|Function, ascending?: boolean, add?: boolean, silent?: boolean): void;
    }

    export class StoreState {
    }

    export class StoreSum {
        average(field: string, records: Model[]): number;
        groupSum(groupValue: any, field: string): number;
        max(field: string, records: Model[]): number|Date;
        min(field: string, records: Model[]): number|Date;
        sum(field: string, records: Model[]): number;
    }

    type StoreSyncConfig = {
        syncDataOnLoad: boolean|object
    }

    export class StoreSync {
        constructor(config?: Partial<StoreSyncConfig>);
    }

    type StoreTreeConfig = {
        transformFlatData: boolean
    }

    export class StoreTree {
        isTree: boolean
        leaves: Model[]
        constructor(config?: Partial<StoreTreeConfig>);
        getChildren(parent: Model): Model[];
        loadChildren(parentRecord: Model): Promise<any>;
        toggleCollapse(idOrRecord: string|number|Model, collapse?: boolean): Promise<any>;
    }

    type TreeNodeConfig = {
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        parentId: string|number|null
        parentIndex: number
    }

    export class TreeNode {
        static convertEmptyParentToLeaf: boolean|object
        allChildren: Model[]
        childLevel: number
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        descendantCount: number
        firstChild: Model
        isLeaf: boolean
        isLoaded: boolean
        isParent: boolean
        lastChild: Model
        parent: Model
        parentId: number|string|null
        parentIndex: number
        previousSiblingsTotalCount: number
        visibleDescendantCount: number
        constructor(config?: Partial<TreeNodeConfig>);
        ancestorsExpanded(store?: Store): boolean;
        appendChild(childRecord: Model|Model[], silent?: boolean): Model|Model[];
        bubble(fn: Function, skipSelf?: boolean): void;
        bubbleWhile(fn: Function, skipSelf?: boolean): boolean;
        contains(childOrId: Model|string|number): boolean;
        getDescendantCount(onlyVisible?: boolean, store?: Store): number;
        insertChild(childRecord: Model|Model[], before?: Model, silent?: boolean): Model|Model[];
        isExpanded(store: Store): boolean;
        removeChild(childRecords: Model|Model[], isMove?: boolean, silent?: boolean): void;
        traverse(fn: Function, skipSelf?: boolean, includeFilteredOutRecords?: boolean): void;
        traverseBefore(fn: Function, skipSelf?: boolean, includeFilteredOutRecords?: boolean): void;
        traverseWhile(fn: Function, skipSelf?: boolean, includeFilteredOutRecords?: boolean): boolean;
    }

    type StateTrackingManagerConfig = {
        autoRecord: boolean
        autoRecordTransactionStopTimeout: number
        bubbleEvents: object
        disabled: boolean
        getTransactionTitle: Function
        listeners: object
        onBeforeDestroy: Function
        onCatchAll: Function
        onDestroy: Function
        onDisabled: Function
        onQueueReset: Function
        onRecordingStart: Function
        onRecordingStop: Function
        onRestoringStart: Function
        onRestoringStop: Function
    }

    export class StateTrackingManager extends Base implements Events {
        autoRecord: boolean
        canRedo: boolean
        canUndo: boolean
        disabled: boolean
        isReady: boolean
        isRecording: boolean
        isRestoring: boolean
        length: number
        position: number
        queue: string[]
        state: StateBase
        stores: Store[]
        transaction: Transaction
        onBeforeDestroy: Function
        onCatchAll: Function
        onDestroy: Function
        onDisabled: Function
        onQueueReset: Function
        onRecordingStart: Function
        onRecordingStop: Function
        onRestoringStart: Function
        onRestoringStop: Function
        constructor(config?: Partial<StateTrackingManagerConfig>);
        addListener(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        addStore(store: Store): void;
        disable(): void;
        enable(): void;
        forEachStore(fn: Function): void;
        hasListener(eventName: string): boolean;
        hasStore(store: Store): boolean;
        on(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        redo(steps?: number): Promise<any>;
        redoAll(): Promise<any>;
        rejectTransaction(): void;
        relayAll(through: Events, prefix: string, transformCase?: boolean): void;
        removeAllListeners(): void;
        removeListener(config: object, thisObj: object): void;
        removeStore(store: Store): void;
        resetQueue(): void;
        resetRedoQueue(): void;
        resetUndoQueue(): void;
        resumeEvents(): void;
        startTransaction(title?: string): void;
        stopTransaction(title?: string): void;
        suspendEvents(queue?: boolean): void;
        trigger(eventName: string, param?: object): boolean|Promise<any>;
        un(config: object, thisObj?: object): void;
        undo(steps?: number): Promise<any>;
        undoAll(): Promise<any>;
    }

    type TransactionConfig = {
        title: string
    }

    export class Transaction {
        length: number
        queue: ActionBase[]
        constructor(config?: Partial<TransactionConfig>);
        addAction(action: ActionBase|object): void;
        redo(): void;
        undo(): void;
    }

    export abstract class ActionBase {
        type: string
        redo(): void;
        undo(): void;
    }

    export class ModelStm {
        stm: StateTrackingManager
    }

    type StoreStmConfig = {
        stm: StateTrackingManager
    }

    export class StoreStm {
        constructor(config?: Partial<StoreStmConfig>);
    }

    export abstract class StateBase {
    }

    type ContextMenuBaseConfig = {
        bubbleEvents: object
        disabled: boolean
        items: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        menu: object
        menuConfig: object
        triggerEvent: string
        type: string
        onContextMenuItem: Function
        onContextMenuToggleItem: Function
    }

    export abstract class ContextMenuBase extends InstancePlugin {
        menu: Menu
        menuContext: object
        onContextMenuItem: Function
        onContextMenuToggleItem: Function
        constructor(config?: Partial<ContextMenuBaseConfig>);
        showContextMenu(event: Event, alignSpec?: object|HTMLElement): void;
    }

    export class AjaxHelper {
        static fetch(url: string, options: object): Promise<any>;
        static get(url: string, options?: object): Promise<any>;
        static mockUrl(url: string, response: object|Function): void;
        static post(url: string, payload: string|object|FormData, options: object): Promise<any>;
    }

    export class AsyncHelper {
        static animationFrame(): Promise<any>;
        static sleep(millis: number): Promise<any>;
        static yield(): Promise<any>;
    }

    export class BrowserHelper {
        static chromeVersion: number
        static edgeVersion: number
        static firefoxVersion: number
        static isAndroid: boolean
        static isChrome: boolean
        static isEdge: boolean
        static isFirefox: boolean
        static isIE11: boolean
        static isLinux: boolean
        static isMac: boolean
        static isMobileSafari: boolean
        static isSafari: boolean
        static isWebkit: boolean
        static isWindows: boolean
        static getCookie(name: string): string;
        static searchParam(paramName: string, defaultValue?: any, search?: string): void;
    }

    export class CSSHelper {
        static findRule(selector: string|Function): CSSRule;
        static insertRule(cssText: string): CSSRule;
    }

    export class DateHelper {
        static defaultFormat: string
        static defaultParseFormat: string
        static nonWorkingDays: object
        static weekStartDay: number
        static add(date: Date|string, amount: number, unit?: string): Date;
        static as(toUnit: string, amount: number|string, fromUnit?: string): number;
        static asMilliseconds(amount: number|string, unit: string): number;
        static asMonths(time: Date): number;
        static betweenLesser(date: Date, start: Date, end: Date): boolean;
        static betweenLesserEqual(date: Date, start: Date, end: Date): boolean;
        static ceil(time: Date, increment: string|number|object, base?: Date): void;
        static clearTime(date: Date, clone?: boolean): Date;
        static clone(date: Date): Date;
        static compare(first: Date, second: Date, unit: string): number;
        static compareUnits(unit1: string, unit2: string): void;
        static constrain(date: Date, min?: Date, max?: Date): Date;
        static copyTimeValues(targetDate: Date, sourceDate: Date): Date;
        static create(definition: object): Date;
        static daysInMonth(date: Date): number;
        static diff(start: Date, end: Date, unit?: string, fractional?: boolean): number;
        static endOf(date: Date): void;
        static floor(time: Date, increment: string|number, base?: Date): void;
        static format(date: Date, format: string): string;
        static formatCount(count: number, unit: string): string;
        static formatDelta(delta: number, options?: object): void;
        static get(date: Date, unit: string): void;
        static getDelta(delta: number, options?: object): object;
        static getDurationInUnit(start: Date, end: Date, unit: string): number;
        static getEndOfPreviousDay(date: Date, noNeedToClearTime: boolean): Date;
        static getFirstDateOfMonth(date: Date): Date;
        static getLastDateOfMonth(date: Date): Date;
        static getLocalizedNameOfUnit(unit: string, plural?: boolean): string;
        static getNext(date: Date, unit: string, increment?: number, weekStartDay?: number): Date;
        static getShortNameOfUnit(unit: string): string;
        static getStartOfNextDay(date: Date, clone: boolean, noNeedToClearTime: boolean): Date;
        static getTime(hours: number|Date, minutes?: number, seconds?: number, ms?: number): Date;
        static getTimeOfDay(date: Date, as?: string): number;
        static getUnitToBaseUnitRatio(baseUnit: string, unit: string, acceptEstimate?: boolean): number;
        static getWeekNumber(date: Date, weekStartDay: number): number[];
        static intersectSpans(date1Start: Date, date1End: Date, date2Start: Date, date2End: Date): boolean;
        static is24HourFormat(format: string): boolean;
        static isAfter(first: Date, second: Date): boolean;
        static isBefore(first: Date, second: Date): boolean;
        static isDate(value: any): boolean;
        static isEqual(first: Date, second: Date, unit: string): boolean;
        static isStartOf(date: Date, unit: string): boolean;
        static isValidDate(date: Date): boolean;
        static max(first: Date, second: Date): Date;
        static min(first: Date, second: Date): Date;
        static normalizeUnit(unit: string): string;
        static parse(dateString: string, format: string): Date;
        static parseDuration(value: string, allowDecimals?: boolean, defaultUnit?: string): object;
        static parseTimeUnit(unitName: any): void;
        static round(time: Date, increment: string|number, base?: Date): void;
        static set(date: Date, unit: string|object, amount: number): Date;
        static startOf(date: Date, unit?: string, clone?: boolean): Date;
        static timeSpanContains(spanStart: Date, spanEnd: Date, otherSpanStart: Date, otherSpanEnd: Date): boolean;
    }

    export class DomHelper {
        static activeElement: HTMLElement
        static scrollBarWidth: number
        static themeInfo: object
        static addClasses(element: HTMLElement, classes: string[]): void;
        static addLeft(element: HTMLElement, x: number): void;
        static addTemporaryClass(element: HTMLElement, cls: string, duration: number, delayable: Delayable): void;
        static addTop(element: HTMLElement, y: number): void;
        static addTranslateX(element: HTMLElement, x: number): void;
        static addTranslateY(element: HTMLElement, y: number): void;
        static alignTo(element: HTMLElement, target: HTMLElement|Rectangle, alignSpec: object, round?: boolean): void;
        static append(parentElement: HTMLElement, elementOrConfig: HTMLElement|object|string): HTMLElement;
        static applyStyle(element: HTMLElement, style: string|object, overwrite?: boolean): void;
        static children(element: HTMLElement, selector: string): HTMLElement[];
        static createElement(config: DomConfig, options: boolean|object): HTMLElement|HTMLElement[]|object;
        static down(element: HTMLElement, selector: string): HTMLElement;
        static elementFromPoint(x: number, y: number): HTMLElement;
        static focusWithoutScrolling(element: HTMLElement): void;
        static forEachChild(element: HTMLElement, fn: Function): void;
        static forEachSelector(element: HTMLElement, selector: string, fn: Function): void;
        static getChild(element: HTMLElement, selector: string): HTMLElement;
        static getEdgeSize(element: HTMLElement, edgeStyle: string, edges?: string): object;
        static getEventElement(event: Event|Element, elementName?: string): Element;
        static getId(element: HTMLElement): void;
        static getOffsetX(element: HTMLElement, container: HTMLElement): number;
        static getOffsetXY(element: HTMLElement, container: HTMLElement): number[];
        static getOffsetY(element: HTMLElement, container: HTMLElement): number;
        static getPageX(element: HTMLElement): number;
        static getPageY(element: HTMLElement): number;
        static getParents(element: HTMLElement): HTMLElement[];
        static getStyleValue(element: HTMLElement, propName: string|string[], inline?: boolean): string|object;
        static getTranslateX(element: HTMLElement): number;
        static getTranslateXY(element: HTMLElement): number[];
        static getTranslateY(element: HTMLElement): number;
        static hasChild(element: HTMLElement, selector: string): boolean;
        static highlight(element: HTMLElement|Rectangle): void;
        static insertBefore(into: HTMLElement, element: HTMLElement, beforeElement: HTMLElement): HTMLElement;
        static insertFirst(into: HTMLElement, element: HTMLElement): HTMLElement;
        static isCustomElement(element: HTMLElement): boolean;
        static isDescendant(parentElement: HTMLElement, childElement: HTMLElement): boolean;
        static isElement(value: any): boolean;
        static isFocusable(element: HTMLElement): boolean;
        static isInView(element: HTMLElement, whole?: boolean): boolean;
        static isNode(value: any): boolean;
        static isVisible(element: HTMLElement): boolean;
        static makeValidId(id: string): string;
        static measureSize(size: string, sourceElement: HTMLElement, round?: boolean): number;
        static measureText(text: string, sourceElement: HTMLElement): number;
        static parseStyle(style: string): object;
        static removeClasses(element: HTMLElement, classes: string[]): void;
        static removeEachSelector(element: HTMLElement, selector: string): void;
        static resetScrollBarWidth(): void;
        static setLeft(element: HTMLElement, x: number|string): void;
        static setLength(element: string|HTMLElement, style?: string, value?: number|string): string;
        static setTheme(newThemeName: string): Promise<any>;
        static setTop(element: HTMLElement, y: number|string): void;
        static setTranslateX(element: HTMLElement, x: number): void;
        static setTranslateXY(element: HTMLElement, x?: number, y?: number): void;
        static setTranslateY(element: HTMLElement, y: number): void;
        static sync(sourceElement: string|HTMLElement, targetElement: HTMLElement): HTMLElement;
        static syncClassList(element: HTMLElement, newClasses: string[]|string|object): void;
        static toggleClasses(element: HTMLElement, classes: string[], force?: boolean): void;
        static up(element: HTMLElement, selector: string): HTMLElement;
    }

    export class DomSync {
        static addChild(parentElement: HTMLElement, childElement: HTMLElement, syncId: string|number): void;
        static getChild(element: HTMLElement, path: string): void;
        static removeChild(parentElement: HTMLElement, childElement: HTMLElement): void;
        static sync(options: object): HTMLElement;
    }

    type DragHelperConfig = {
        bubbleEvents: object
        cloneTarget: boolean
        constrain: boolean
        containers: HTMLElement[]
        dragThreshold: number
        dragWithin: HTMLElement
        dropTargetSelector: string
        hideOriginalElement: boolean
        ignoreSelector: string
        invalidCls: string
        isElementDraggable: Function
        listeners: object
        lockX: boolean
        lockY: boolean
        maxX: number
        maxY: number
        minX: number
        minY: number
        mode: string
        outerElement: HTMLElement
        scrollManager: ScrollManager
        targetSelector: string
        touchStartDelay: number
        onBeforeDestroy: Function
        onBeforeDragStart: Function
        onCatchAll: Function
        onDestroy: Function
        onDrag: Function
        onDragStart: Function
        onDrop: Function
    }

    export class DragHelper extends Base implements Events {
        onBeforeDestroy: Function
        onBeforeDragStart: Function
        onCatchAll: Function
        onDestroy: Function
        onDrag: Function
        onDragStart: Function
        onDrop: Function
        constructor(config: Partial<DragHelperConfig>);
        abort(): void;
        addListener(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        createProxy(): void;
        hasListener(eventName: string): boolean;
        on(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        relayAll(through: Events, prefix: string, transformCase?: boolean): void;
        removeAllListeners(): void;
        removeListener(config: object, thisObj: object): void;
        resumeEvents(): void;
        suspendEvents(queue?: boolean): void;
        trigger(eventName: string, param?: object): boolean|Promise<any>;
        un(config: object, thisObj?: object): void;
    }

    export class EventHelper {
        static dblClickTime: number
        static longPressTime: number
        static addListener(element: HTMLElement, eventName: string|object, handler?: Function, options?: object): Function;
        static getClientPoint(event: Event): Point;
        static getDistanceBetween(event1: Event, event2: Event): number;
        static getPagePoint(event: Event): Point;
        static getXY(event: Event): number[];
        static on(options: object): Function;
    }

    export class ObjectHelper {
        static allKeys(object: object): string[];
        static assertArray(value: object, name: string): void;
        static assertBoolean(value: object, name: string): void;
        static assertClass(value: object, name: string): void;
        static assertFunction(value: object, name: string): void;
        static assertInstance(value: object, name: string): void;
        static assertNumber(value: object, name: string): void;
        static assertObject(value: object, name: string): void;
        static assertString(value: object, name: string): void;
        static assertType(value: object, type: string, name: string, allowNull?: boolean): void;
        static assign(dest: object, sources: object): object;
        static assignIf(dest: object, sources: object): object;
        static cleanupProperties(object: object, keepNull?: boolean): object;
        static clone(value: any, handler?: Function): any;
        static copyProperties(dest: object, source: object, props: string[]): void;
        static copyPropertiesIf(dest: object, source: object, props: string[]): void;
        static createTruthyKeys(source: string|string[]): void;
        static getMapPath(map: Map<any, any>, path: string|number|string[]|number[], defaultValue?: object): void;
        static getPath(object: object, path: string): any;
        static getPropertyDescriptor(object: object, propertyName: string): object;
        static getTruthyKeys(source: object): string[];
        static getTruthyValues(source: object): string[];
        static isDeeplyEqual(a: object, b: object, options?: object): boolean;
        static isEmpty(object: object): boolean;
        static isEqual(a: any, b: any): any;
        static isLessThan(a: any, b: any): boolean;
        static isMoreThan(a: any, b: any): boolean;
        static isObject(value: object): boolean;
        static isPartial(a: any, b: any): boolean;
        static keys(object: object, ignore?: object|Function): string[];
        static merge(dest: object, sources: object): object;
        static pathExists(object: object, path: string): boolean;
        static removeAllProperties(object: object): object;
        static round(number: number, digits: number): number;
        static roundTo(number: number, step?: number): number;
        static setPath(object: object, path: string, value: any): object;
        static toFixed(number: number, digits: number): string;
        static transformArrayToNamedObject(arrayOfItems: object[], prop?: string): object;
        static transformNamedObjectToArray(namedItems: object, prop?: string): object[];
        static typeOf(value: any): string;
    }

    export class StringHelper {
        static capitalize(string: string): string;
        static capitalizeFirstLetter(string: string): string;
        static decodeHtml(str: string): string;
        static encodeHtml(str: string): string;
        static lowercaseFirstLetter(string: string): string;
        static safeJsonParse(string: string): object;
        static safeJsonStringify(object: object, replacer?: Function|string[]|number[], space?: string|number): object;
        static uncapitalize(string: string): string;
        static xss(): void;
    }

    export class WidgetHelper {
        static append(widget: object|object[], config?: HTMLElement|string|object): Widget[];
        static attachTooltip(element: HTMLElement, configOrText: string|object): object;
        static createWidget(config: object): object;
        static destroyTooltipAttached(element: HTMLElement): void;
        static fromElement(element: HTMLElement|Event, type?: string|Function, limit?: HTMLElement|number): Widget;
        static getById(Id: string): Widget;
        static hasTooltipAttached(element: HTMLElement): boolean;
        static mask(element: HTMLElement, msg?: string): void;
        static openPopup(element: HTMLElement, config: object): any|object;
        static showContextMenu(element: HTMLElement|number[], config: object): any|object;
        static toast(msg: string): void;
        static unmask(element: HTMLElement): void;
    }

    export class XMLHelper {
        static convertFromObject(obj: object, options?: object): string;
    }

    export class DataGenerator {
        static generateData(count: number, randomHeight?: boolean, initialId?: number, reset?: boolean): object[];
        static generateRow(): object;
    }

    export class DomClassList {
        value: string
        values: string[]
        constructor(classes: string|object);
        add(classes: string): void;
        assign(classList: object): void;
        clone(): DomClassList;
        contains(className: string): boolean;
        isEqual(other: DomClassList|string): boolean;
        remove(classes: string): void;
        split(): string[];
        trim(): string;
    }

    export class Fullscreen {
        static enabled: boolean
        static isFullscreen: boolean
        static exit(): Promise<any>;
        static onFullscreenChange(fn: Function): void;
        static request(element: HTMLElement): Promise<any>;
        static unFullscreenChange(fn: Function): void;
    }

    type NumberFormatConfig = {
        fraction: number|number[]
        integer: number
        significant: number|number[]
        template: string
    }

    export class NumberFormat {
        constructor(config?: Partial<NumberFormatConfig>);
        as(change: string|object, cacheAs?: string): NumberFormat;
        format(value: number): string;
        parse(value: string, strict?: boolean): number;
        parseStrict(value: string): number;
        round(value: number|string): number;
        truncate(value: number|string): number;
    }

    export class Point extends Rectangle {
        constrain(into: Rectangle): void;
    }

    export class RandomGenerator {
        fromArray(array: any[]): any;
        nextRandom(max: number): number;
        reset(): void;
    }

    export class Rectangle {
        bottom: number
        center: Point
        height: number
        left: number
        right: number
        top: number
        width: number
        x: number
        y: number
        static client(element: HTMLElement, relativeTo?: HTMLElement, ignorePageScroll?: boolean): Rectangle;
        static content(element: HTMLElement, relativeTo?: HTMLElement, ignorePageScroll?: boolean): Rectangle;
        static from(element: HTMLElement, relativeTo?: HTMLElement, ignorePageScroll?: boolean): Rectangle;
        static fromScreen(element: HTMLElement, relativeTo?: HTMLElement): Rectangle;
        static inner(element: HTMLElement, relativeTo?: HTMLElement, ignorePageScroll?: boolean): Rectangle;
        static union(rectangles: Rectangle[]): Rectangle;
        adjust(x: number, y: number, width: number, height: number): void;
        alignTo(spec: object): Rectangle;
        clone(): void;
        constrainTo(constrainTo: Rectangle, strict: boolean): void;
        contains(other: Rectangle): boolean;
        highlight(): void;
        intersect(other: Rectangle, useBoolean?: boolean, allowZeroDimensions?: boolean): Rectangle|boolean;
        moveTo(x: number, y: number): void;
        roundPx(devicePixelRatio?: number): void;
        translate(x: number, y: number): void;
    }

    type ScrollerConfig = {
        bubbleEvents: object
        element: HTMLElement
        listeners: object
        overflowX: string|boolean
        overflowY: string|boolean
        translate: boolean
        widget: HTMLElement
        onBeforeDestroy: Function
        onCatchAll: Function
        onDestroy: Function
        onScroll: Function
        onScrollend: Function
    }

    export class Scroller extends Base implements Events, Delayable {
        clientHeight: number
        clientWidth: number
        id: string
        maxX: number
        maxY: number
        overflowX: boolean|string
        overflowY: boolean|string
        scrollHeight: number
        scrollWidth: number
        viewport: Rectangle
        x: number
        y: number
        onBeforeDestroy: Function
        onCatchAll: Function
        onDestroy: Function
        onScroll: Function
        onScrollend: Function
        constructor(config?: Partial<ScrollerConfig>);
        static scrollIntoView(element: HTMLElement, options?: object): Promise<any>;
        addListener(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        addPartner(otherScroller: Scroller, axes?: string|object): void;
        hasListener(eventName: string): boolean;
        hasScrollbar(axis?: any): void;
        on(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        relayAll(through: Events, prefix: string, transformCase?: boolean): void;
        removeAllListeners(): void;
        removeListener(config: object, thisObj: object): void;
        removePartner(otherScroller: Scroller): void;
        resumeEvents(): void;
        scrollBy(xDelta?: number, yDelta?: number, options?: object|boolean): Promise<any>;
        scrollTo(toX?: number, toY?: number, options?: object|boolean): Promise<any>;
        suspendEvents(queue?: boolean): void;
        trigger(eventName: string, param?: object): boolean|Promise<any>;
        un(config: object, thisObj?: object): void;
    }

    export class LocaleHelper {
        static mergeLocales(locales: object): object;
        static publishLocale(localeName: string, config: object): void;
        static trimLocale(locale: object, trimLocale: object): void;
    }

    export class LocaleManagerSingleton {
        locale: string|object
        locales: object
        throwOnMissingLocale: boolean
        onLocale: Function
        applyLocale(name: string): boolean|Promise<any>;
        extendLocale(name: string, config: object): void;
        registerLocale(name: string, config: object): void;
    }

    export const LocaleManager : LocaleManagerSingleton

    type LocalizableConfig = {
        localeClass: Base
        localizableProperties: string[]
    }

    export class Localizable {
        localeManager: typeof LocaleManager
        constructor(config?: Partial<LocalizableConfig>);
        static optionalL(text: string, templateData?: object): string;
        L(text: string, templateData?: object): string;
        updateLocalization(): void;
    }

    export class Delayable {
    }

    type EventsConfig = {
        bubbleEvents: object
        listeners: object
        onBeforeDestroy: Function
        onCatchAll: Function
        onDestroy: Function
    }

    export class Events {
        onBeforeDestroy: Function
        onCatchAll: Function
        onDestroy: Function
        constructor(config?: Partial<EventsConfig>);
        addListener(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        hasListener(eventName: string): boolean;
        on(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        relayAll(through: Events, prefix: string, transformCase?: boolean): void;
        removeAllListeners(): void;
        removeListener(config: object, thisObj: object): void;
        resumeEvents(): void;
        suspendEvents(queue?: boolean): void;
        trigger(eventName: string, param?: object): boolean|Promise<any>;
        un(config: object, thisObj?: object): void;
    }

    type InstancePluginConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        onBeforeDestroy: Function
        onCatchAll: Function
        onDestroy: Function
        onDisable: Function
        onEnable: Function
    }

    export class InstancePlugin extends Base implements Localizable, Events {
        client: Widget
        disabled: boolean
        localeManager: typeof LocaleManager
        onBeforeDestroy: Function
        onCatchAll: Function
        onDestroy: Function
        onDisable: Function
        onEnable: Function
        constructor(config?: Partial<InstancePluginConfig>);
        static optionalL(text: string, templateData?: object): string;
        L(text: string, templateData?: object): string;
        addListener(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        doDisable(): void;
        hasListener(eventName: string): boolean;
        on(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        relayAll(through: Events, prefix: string, transformCase?: boolean): void;
        removeAllListeners(): void;
        removeListener(config: object, thisObj: object): void;
        resumeEvents(): void;
        suspendEvents(queue?: boolean): void;
        trigger(eventName: string, param?: object): boolean|Promise<any>;
        un(config: object, thisObj?: object): void;
        updateLocalization(): void;
    }

    type LoadMaskableConfig = {
        loadMask: string|object|null
        loadMaskDefaults: object|Mask|Partial<MaskConfig>
        loadMaskError: object|Mask|Partial<MaskConfig>
        syncMask: string|object|null
    }

    export class LoadMaskable {
        constructor(config?: Partial<LoadMaskableConfig>);
    }

    export class Override {
        static apply(override: object): void;
    }

    type PluggableConfig = {
        plugins: Function[]
    }

    export class Pluggable {
        plugins: object
        constructor(config?: Partial<PluggableConfig>);
        addPlugins(plugins: Function[]): void;
        getPlugin(pluginClassOrName: string|Function): object;
        hasPlugin(pluginClassOrName: string|Function): boolean;
    }

    export class State {
        state: object
    }

    type ClickRepeaterConfig = {
        accelerateDuration: number
        delay: number
        delegate: string
        element: HTMLElement
        endRate: number
        startRate: number
    }

    export class ClickRepeater {
        constructor(config?: Partial<ClickRepeaterConfig>);
    }

    type CollectionConfig = {
        autoFilter: boolean
        autoSort: boolean
        extraKeys: string[]|object[]
        idProperty: string
        sorters: object[]
        onChange: Function
        onNoChange: Function
    }

    export class Collection {
        allValues: object[]
        count: number
        filterFunction: Function
        filters: Collection
        generation: number
        idProperty: string
        isFiltered: boolean
        isSorted: boolean
        sortFunction: Function
        sorters: Collection
        totalCount: number
        values: object[]
        onChange: Function
        onNoChange: Function
        constructor(config?: Partial<CollectionConfig>);
        add(items: object): void;
        addFilter(filter: object): CollectionFilter;
        addSorter(sorter: object): CollectionSorter;
        changeId(item: string|number|object, newId: string|number): void;
        clear(): void;
        find(fn: Function, ignoreFilters?: boolean): object;
        findIndex(propertyName: string, value: any, ignoreFilters?: boolean): number;
        findItem(propertyName: string, value: any, ignoreFilters?: boolean): object|Set<any>;
        forEach(fn: Function, ignoreFilters?: boolean): void;
        get(id: any, ignoreFilters?: boolean): object;
        getBy(propertyName: string, value: any, ignoreFilters?: boolean): object;
        includes(item: object|string|number, ignoreFilters?: boolean): boolean;
        indexOf(item: object|string|number, ignoreFilters?: boolean): number;
        map(fn: Function, ignoreFilters?: boolean): object[];
        move(items: object|object[], beforeItem?: object): number;
        remove(items: object): void;
        splice(index?: number, toRemove?: object[]|number, toAdd?: object[]|object): void;
    }

    type CollectionFilterConfig = {
        caseSensitive: boolean
        convert: Function
        filterBy: Function
        id: string
        operator: string
        property: string
        value: any
    }

    export class CollectionFilter {
        filterBy: Function
        operator: string
        property: string
        value: any
        constructor(config?: Partial<CollectionFilterConfig>);
    }

    type CollectionSorterConfig = {
        convert: Function
        direction: string
        id: string
        property: string
        sortFn: Function
        useLocaleSort: boolean|string|object
    }

    export class CollectionSorter {
        constructor(config?: Partial<CollectionSorterConfig>);
    }

    type MonthConfig = {
        date: Date|string
        hideNonWorkingDays: boolean
        nonWorkingDays: object
        sixWeeks: boolean
        weekStartDay: number
        onDateChange: Function
        onMonthChange: Function
        onWeekChange: Function
        onYearChange: Function
    }

    export class Month {
        canonicalDayNumbers: number[]
        dayColumnIndex: number[]
        dayCount: number
        endDate: Date
        startDate: Date
        visibleDayColumnIndex: number[]
        weekCount: number
        weekLength: number
        onDateChange: Function
        onMonthChange: Function
        onWeekChange: Function
        onYearChange: Function
        constructor(config?: Partial<MonthConfig>);
        eachDay(fn: Function): void;
        eachWeek(fn: Function): void;
        getWeekNumber(date: Date): number[];
        getWeekStart(week: number|number[]): void;
    }

    type ScrollManagerConfig = {
        direction: string
        element: HTMLElement
        scrollSpeed: number
        startScrollDelay: number
        stopScrollWhenPointerOut: boolean
        zoneWidth: number
    }

    export class ScrollManager {
        isScrolling: boolean
        constructor(config?: Partial<ScrollManagerConfig>);
        startMonitoring(config: object): Function;
        stopMonitoring(element?: HTMLElement|HTMLElement[]): void;
    }

    type ButtonConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        badge: string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        color: string
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        href: string
        html: string
        htmlCls: string|object
        icon: string
        iconAlign: string
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        menu: object|object[]|Widget|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        owner: Widget
        positioned: boolean
        pressed: boolean
        pressedIcon: string
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        target: string
        text: string
        textAlign: string
        title: string
        toggleGroup: string
        toggleable: boolean
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
        onAction: Function
        onClick: Function
        onToggle: Function
    }

    export class Button extends Widget implements Badge {
        badge: string
        icon: string
        iconAlign: string
        menu: Widget
        pressed: boolean
        pressedIcon: string
        text: string
        onAction: Function
        onClick: Function
        onToggle: Function
        constructor(config?: Partial<ButtonConfig>);
        eachWidget(fn: Function, deep?: boolean): boolean;
        toggle(pressed: boolean): void;
    }

    type ButtonGroupConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string
        color: string
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object[]|Button[]|Partial<ButtonConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        textContent: boolean
        title: string
        toggleGroup: boolean
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
        onAction: Function
        onClick: Function
        onToggle: Function
    }

    export class ButtonGroup extends Container {
        onAction: Function
        onClick: Function
        onToggle: Function
        constructor(config?: Partial<ButtonGroupConfig>);
    }

    type CalendarPanelConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        cellRenderer: Function|string
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        date: Date|string
        dayNameFormat: string
        defaultBindProperty: string
        defaults: object
        disableWeekends: boolean
        disabled: boolean
        disabledDates: Function|Date[]|string
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        footer: object|string
        header: string|PanelHeader
        headerRenderer: Function|string
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minColumnWidth: number
        minHeight: string|number
        minRowHeight: number
        minWidth: string|number
        monitorResize: boolean
        month: Month|object|Partial<MonthConfig>
        namedItems: object
        nonWorkingDays: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showWeekColumn: boolean
        showWeekNumber: boolean
        sixWeeks: boolean
        strips: object
        style: string
        tab: boolean|object
        tag: string
        tbar: object[]|object
        textAlign: string
        textContent: boolean
        tip: object
        title: string
        tools: object
        tooltip: string|object
        trapFocus: boolean
        weekRenderer: Function|string
        weekStartDay: number
        weight: number
        width: string|number
        x: number
        y: number
        onDateChange: Function
        onRefresh: Function
    }

    export class CalendarPanel extends Panel {
        date: Date
        endDate: Date
        startDate: Date
        visibleWeekCount: number
        onDateChange: Function
        onRefresh: Function
        constructor(config?: Partial<CalendarPanelConfig>);
        refresh(): void;
        updateDate(): void;
        updateWeekStartDay(): void;
    }

    type CheckboxConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoComplete: string
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        centered: boolean
        checked: boolean
        clearable: boolean|object
        cls: string|object
        color: string
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        editable: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        keyStrokeChangeDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        name: string
        owner: Widget
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        text: string
        textAlign: string
        title: string
        tooltip: string|object
        triggers: object
        value: string
        weight: number
        width: string|number
        x: number
        y: number
        onAction: Function
        onBeforeChange: Function
        onChange: Function
    }

    export class Checkbox extends Field {
        checked: boolean
        name: string
        value: string
        onAction: Function
        onBeforeChange: Function
        onChange: Function
        constructor(config?: Partial<CheckboxConfig>);
        check(): void;
        toggle(): void;
        uncheck(): void;
    }

    type ChipViewConfig = {
        activateOnMouseover: boolean
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        allowGroupSelect: boolean
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        closable: boolean
        closeHandler: string|Function
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        groupHeaderTpl: Function
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        html: string
        htmlCls: string|object
        iconTpl: Function
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemTpl: Function
        items: object[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        multiSelect: boolean
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        selectAllItem: boolean|string
        selected: Collection|object|Partial<CollectionConfig>
        showAnimation: boolean|object
        store: object|Store|Partial<StoreConfig>
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        title: string
        toggleAllIfCtrlPressed: boolean
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class ChipView extends List {
        constructor(config?: Partial<ChipViewConfig>);
    }

    type ComboConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoComplete: string
        autoExpand: boolean
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        caseSensitive: boolean
        centered: boolean
        chipView: object
        clearTextOnPickerHide: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        displayField: string
        displayValueRenderer: Function
        dock: string
        draggable: boolean|object
        editable: boolean
        emptyText: string
        encodeFilterParams: Function
        filterOnEnter: boolean
        filterOperator: string
        filterParamName: string
        filterSelected: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hidePickerOnSelect: boolean
        hideTrigger: boolean
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        items: object[]|string[]|object
        keyStrokeChangeDelay: number
        keyStrokeFilterDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listCls: string
        listItemTpl: Function
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        minChars: number
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        multiSelect: boolean
        name: string
        overlayAnchor: boolean
        owner: Widget
        picker: object
        pickerAlignElement: string
        pickerWidth: number
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        primaryFilter: object
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        store: Store
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggerAction: string
        triggers: object
        validateFilter: boolean
        value: string|number[]|string[]
        valueField: string
        weight: number
        width: string|number
        x: number
        y: number
        onAction: Function
        onInput: Function
        onSelect: Function
    }

    export class Combo extends PickerField {
        static queryLast: string
        filterOperator: string
        isEmpty: boolean
        record: Model[]
        records: Model[]
        store: Store|object|Partial<StoreConfig>
        value: object
        valueCollection: Collection
        onAction: Function
        onInput: Function
        onSelect: Function
        constructor(config?: Partial<ComboConfig>);
    }

    type ContainerConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        textContent: boolean
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
        onBeforeSetRecord: Function
    }

    export class Container extends Widget {
        isSettingValues: boolean
        isValid: boolean
        items: Widget[]|object|Partial<WidgetConfig>
        layout: Layout
        layoutStyle: object
        record: Model
        values: object
        widgetMap: object
        onBeforeSetRecord: Function
        constructor(config?: Partial<ContainerConfig>);
        add(toAdd: object|object[]|Widget|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]): Widget|Widget[];
        getWidgetById(id: string): Widget;
        insert(toAdd: Widget, index: number|Widget): Widget;
        processWidgetConfig(): void;
        remove(toRemove: Widget): Widget|Widget[];
        removeAll(): Widget[];
    }

    type DateFieldConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoComplete: string
        autoExpand: boolean
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        centered: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        editable: boolean
        flex: number|string
        floating: boolean
        format: string
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        keepTime: boolean|Date|string
        keyStrokeChangeDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        max: string|Date
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        min: string|Date
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        name: string
        owner: Widget
        picker: object
        pickerAlignElement: string
        pickerFormat: string
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        step: string|number|object
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggers: object
        value: string|Date
        weekStartDay: number
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class DateField extends PickerField {
        format: string
        max: string|Date
        min: string|Date
        step: string|number|object
        value: string|Date
        constructor(config?: Partial<DateFieldConfig>);
    }

    type DatePickerConfig = {
        activeDate: Date
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        cellRenderer: Function|string
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        date: Date
        dayNameFormat: string
        defaultBindProperty: string
        defaults: object
        disableWeekends: boolean
        disabled: boolean
        disabledDates: Function|Date[]|string
        dock: string
        draggable: boolean|object
        editMonth: boolean
        editOnHover: boolean
        flex: number|string
        floating: boolean
        focusDisabledDates: boolean
        footer: object|string
        header: string|PanelHeader
        headerRenderer: Function|string
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxDate: Date
        maxHeight: string|number
        maxWidth: string|number
        minColumnWidth: number
        minDate: Date
        minHeight: string|number
        minRowHeight: number
        minWidth: string|number
        monitorResize: boolean
        month: Month|object|Partial<MonthConfig>
        multiSelect: boolean
        namedItems: object
        nonWorkingDays: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showWeekColumn: boolean
        showWeekNumber: boolean
        sixWeeks: boolean
        strips: object
        style: string
        tab: boolean|object
        tag: string
        tbar: object[]|object
        textAlign: string
        textContent: boolean
        tip: object
        title: string
        tools: object
        tooltip: string|object
        trapFocus: boolean
        weekRenderer: Function|string
        weekStartDay: number
        weight: number
        width: string|number
        x: number
        y: number
        onSelectionChange: Function
    }

    export class DatePicker extends CalendarPanel {
        onSelectionChange: Function
        constructor(config?: Partial<DatePickerConfig>);
    }

    type DateTimeFieldConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoComplete: string
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        centered: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        dateField: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        editable: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        keyStrokeChangeDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        name: string
        owner: Widget
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        timeField: object
        title: string
        tooltip: string|object
        triggers: object
        value: string
        weekStartDay: number
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class DateTimeField extends Field {
        dateField: DateField
        timeField: TimeField
        constructor(config?: Partial<DateTimeFieldConfig>);
    }

    type DisplayFieldConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoComplete: string
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        centered: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        editable: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        keyStrokeChangeDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        name: string
        owner: Widget
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        template: Function
        textAlign: string
        title: string
        tooltip: string|object
        triggers: object
        value: string
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class DisplayField extends Field {
        constructor(config?: Partial<DisplayFieldConfig>);
    }

    type DurationFieldConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        allowNegative: boolean
        allowedUnits: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoComplete: string
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        centered: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        decimalPrecision: number
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        editable: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        keyStrokeChangeDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        magnitude: number
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        max: string
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        min: string
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        name: string
        owner: Widget
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        step: number
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggers: object
        unit: string
        useAbbreviation: boolean
        value: object|string
        weight: number
        width: string|number
        x: number
        y: number
        onAction: Function
        onChange: Function
    }

    export class DurationField extends TextField {
        magnitude: number
        milliseconds: number
        unit: string
        value: string|number|object|Duration
        onAction: Function
        onChange: Function
        constructor(config?: Partial<DurationFieldConfig>);
    }

    type EditorConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        blurAction: string
        bubbleEvents: object
        cancelKey: string
        centered: boolean
        cls: string|object
        completeKey: string
        completeOnChange: boolean
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        inputField: object|string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        invalidAction: string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        textContent: boolean
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
        onBeforeCancel: Function
        onBeforeComplete: Function
        onBeforeStart: Function
        onCancel: Function
        onComplete: Function
        onKeypress: Function
        onStart: Function
    }

    export class Editor extends Container {
        onBeforeCancel: Function
        onBeforeComplete: Function
        onBeforeStart: Function
        onCancel: Function
        onComplete: Function
        onKeypress: Function
        onStart: Function
        constructor(config?: Partial<EditorConfig>);
        cancelEdit(): void;
        completeEdit(): void;
        startEdit(editObject: object): void;
    }

    type FieldConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoComplete: string
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        centered: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        editable: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        keyStrokeChangeDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        name: string
        owner: Widget
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggers: object
        value: string
        weight: number
        width: string|number
        x: number
        y: number
        onAction: Function
        onChange: Function
        onClear: Function
        onInput: Function
        onTrigger: Function
    }

    export abstract class Field extends Widget implements Badge {
        static errorTip: Tooltip
        badge: string
        isEmpty: boolean
        isEmptyInput: boolean
        isValid: boolean
        label: string
        triggers: object
        value: any
        onAction: Function
        onChange: Function
        onClear: Function
        onInput: Function
        onTrigger: Function
        constructor(config?: Partial<FieldConfig>);
        clear(): void;
        clearError(error?: string, silent?: boolean): void;
        getErrors(): string[];
        select(start?: number, end?: number): void;
        setError(error: string, silent?: boolean): void;
    }

    type FileFieldConfig = {
        accept: string
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoComplete: string
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        centered: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        editable: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        keyStrokeChangeDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        multiple: boolean
        name: string
        owner: Widget
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggers: object
        value: string
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class FileField extends Field {
        files: FileList
        constructor(config?: Partial<FileFieldConfig>);
        clear(): void;
    }

    type FilePickerConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        buttonConfig: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        fileFieldConfig: object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        textContent: boolean
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
        onChange: Function
        onClear: Function
    }

    export class FilePicker extends Container {
        files: FileList
        onChange: Function
        onClear: Function
        constructor(config?: Partial<FilePickerConfig>);
        clear(): void;
    }

    type FilterFieldConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoComplete: string
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        centered: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        editable: boolean
        field: string
        filterFunction: Function
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        keyStrokeChangeDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        name: string
        owner: Widget
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        store: Store
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggers: object
        value: string
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class FilterField extends TextField {
        constructor(config?: Partial<FilterFieldConfig>);
    }

    type ListConfig = {
        activateOnMouseover: boolean
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        allowGroupSelect: boolean
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        groupHeaderTpl: Function
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemTpl: Function
        items: object[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        multiSelect: boolean
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        selectAllItem: boolean|string
        selected: Collection|object|Partial<CollectionConfig>
        showAnimation: boolean|object
        store: object|Store|Partial<StoreConfig>
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        title: string
        toggleAllIfCtrlPressed: boolean
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
        onItem: Function
    }

    export class List extends Widget {
        items: object[]
        store: Store
        onItem: Function
        constructor(config?: Partial<ListConfig>);
    }

    type MaskConfig = {
        icon: string
        mode: string
        owner: object|Widget|Partial<WidgetConfig>
        showDelay: number
        target: string|HTMLElement
        text: string
    }

    export class Mask {
        maxProgress: number
        progress: number
        constructor(config?: Partial<MaskConfig>);
        static mask(text: string|object, target: HTMLElement): Mask;
        static unmask(element: HTMLElement): Promise<any>;
        close(): Promise<any>;
        hide(): Promise<any>;
        show(): void;
    }

    type MenuConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoShow: boolean
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        focusOnHover: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maximizable: boolean
        maximized: boolean
        minHeight: string|number
        minWidth: string|number
        modal: boolean
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showOnClick: boolean
        strips: object
        style: string
        tab: boolean|object
        tag: string
        tbar: object[]|object
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        trapFocus: boolean
        weight: number
        width: string|number
        x: number
        y: number
        onItem: Function
        onToggle: Function
    }

    export class Menu extends Popup {
        currentSubMenu: Menu
        isSubMenu: boolean
        parentMenu: Menu
        selectedElement: HTMLElement
        onItem: Function
        onToggle: Function
        constructor(config?: Partial<MenuConfig>);
    }

    type MenuItemConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        checked: boolean
        closeParent: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        href: string
        html: string
        htmlCls: string|object
        icon: string
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        menu: object|object[]
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        target: string
        text: string
        textAlign: string
        title: string
        toggleGroup: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
        onItem: Function
        onToggle: Function
    }

    export class MenuItem extends Widget {
        checked: boolean
        menu: Widget
        onItem: Function
        onToggle: Function
        constructor(config?: Partial<MenuItemConfig>);
        doAction(): void;
    }

    export class MessageDialogSingleton extends Popup {
        cancelButton: number
        okButton: number
        alert(options: object): Promise<any>;
        confirm(options: object): Promise<any>;
        prompt(options: object): Promise<any>;
    }

    export const MessageDialog : MessageDialogSingleton

    type NumberFieldConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoComplete: string
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        centered: boolean
        changeOnSpin: boolean|number
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        decimalPrecision: number
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        editable: boolean
        flex: number|string
        floating: boolean
        format: string|object|NumberFormat|Partial<NumberFormatConfig>
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputType: string
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        keyStrokeChangeDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        largeStep: number
        leadingZeroes: number
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        max: number
        maxHeight: string|number
        maxWidth: string|number
        min: number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        name: string
        owner: Widget
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        step: number
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggers: object
        value: number
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class NumberField extends Field {
        step: number
        constructor(config?: Partial<NumberFieldConfig>);
        changeValue(): void;
    }

    type PagingToolbarConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        overflow: string|object|null
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        store: AjaxStore
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        weight: number
        widgetCls: string
        width: string|number
        x: number
        y: number
    }

    export class PagingToolbar extends Toolbar {
        constructor(config?: Partial<PagingToolbarConfig>);
    }

    type PanelConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        footer: object|string
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        strips: object
        style: string
        tab: boolean|object
        tag: string
        tbar: object[]|object
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        trapFocus: boolean
        weight: number
        width: string|number
        x: number
        y: number
        onToolClick: Function
    }

    export class Panel extends Container {
        bbar: Toolbar
        tbar: Toolbar
        tools: object
        onToolClick: Function
        constructor(config?: Partial<PanelConfig>);
    }

    type PickerFieldConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoComplete: string
        autoExpand: boolean
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        centered: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        editable: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        keyStrokeChangeDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        name: string
        owner: Widget
        picker: object
        pickerAlignElement: string
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggers: object
        value: string
        weight: number
        width: string|number
        x: number
        y: number
    }

    export abstract class PickerField extends TextField {
        picker: Widget
        constructor(config?: Partial<PickerFieldConfig>);
        eachWidget(fn: Function, deep?: boolean): boolean;
        hidePicker(): void;
        showPicker(): void;
        togglePicker(): void;
    }

    type PopupConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoShow: boolean
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maximizable: boolean
        maximized: boolean
        minHeight: string|number
        minWidth: string|number
        modal: boolean
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showOnClick: boolean
        strips: object
        style: string
        tab: boolean|object
        tag: string
        tbar: object[]|object
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        trapFocus: boolean
        weight: number
        width: string|number
        x: number
        y: number
        onBeforeClose: Function
    }

    export class Popup extends Panel {
        maximized: boolean
        onBeforeClose: Function
        constructor(config?: Partial<PopupConfig>);
        close(): void;
    }

    type SlideToggleConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoComplete: string
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        centered: boolean
        checked: boolean
        clearable: boolean|object
        cls: string|object
        color: string
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        editable: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        keyStrokeChangeDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        name: string
        owner: Widget
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        text: string
        textAlign: string
        title: string
        tooltip: string|object
        triggers: object
        value: string
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class SlideToggle extends Checkbox {
        constructor(config?: Partial<SlideToggleConfig>);
    }

    type SliderConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        max: number
        maxHeight: string|number
        maxWidth: string|number
        min: number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showTooltip: boolean
        showValue: boolean
        step: number
        style: string
        tab: boolean|object
        tag: string
        text: string
        textAlign: string
        title: string
        tooltip: string|object
        value: number
        weight: number
        width: string|number
        x: number
        y: number
        onChange: Function
        onInput: Function
    }

    export class Slider extends Widget {
        max: number
        min: number
        step: number
        text: string
        value: number
        onChange: Function
        onInput: Function
        constructor(config?: Partial<SliderConfig>);
    }

    type SplitterConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        orientation: string
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class Splitter extends Widget {
        currentOrientation: string
        orientation: string
        constructor(config?: Partial<SplitterConfig>);
    }

    type TabConfig = {
        active: boolean
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        badge: string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        color: string
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        href: string
        html: string
        htmlCls: string|object
        icon: string
        iconAlign: string
        id: string
        index: number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        isFirst: boolean
        isLast: boolean
        item: Widget
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        menu: object|object[]|Widget|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        owner: Widget
        positioned: boolean
        pressed: boolean
        pressedIcon: string
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tabPanel: TabPanel
        tag: string
        target: string
        text: string
        textAlign: string
        title: string
        titleProperty: string
        titleSource: string
        toggleGroup: string
        toggleable: boolean
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class Tab extends Button {
        constructor(config?: Partial<TabConfig>);
    }

    type TabBarConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        overflow: string|object|null
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        weight: number
        widgetCls: string
        width: string|number
        x: number
        y: number
    }

    export class TabBar extends Toolbar {
        constructor(config?: Partial<TabBarConfig>);
    }

    type TabPanelConfig = {
        activeTab: number
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        animateTabChange: boolean
        appendTo: HTMLElement|string
        autoHeight: boolean
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tabMaxWidth: number
        tabMinWidth: number
        tag: string
        textAlign: string
        textContent: boolean
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
        onBeforeTabChange: Function
        onTabChange: Function
    }

    export class TabPanel extends Container {
        activeIndex: number
        activeItem: Widget
        activeTab: number
        onBeforeTabChange: Function
        onTabChange: Function
        constructor(config?: Partial<TabPanelConfig>);
    }

    type TextAreaFieldConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoComplete: string
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        centered: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        editable: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inline: boolean
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        keyStrokeChangeDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        name: string
        owner: Widget
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        required: boolean
        resize: string
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggers: object
        value: string
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class TextAreaField extends Field {
        constructor(config?: Partial<TextAreaFieldConfig>);
    }

    type TextFieldConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoComplete: string
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        centered: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        editable: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        keyStrokeChangeDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        name: string
        owner: Widget
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggers: object
        value: string
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class TextField extends Field {
        constructor(config?: Partial<TextFieldConfig>);
    }

    type TimeFieldConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoComplete: string
        autoExpand: boolean
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        centered: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        editable: boolean
        flex: number|string
        floating: boolean
        format: string
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        keyStrokeChangeDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        max: string|Date
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        min: string|Date
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        name: string
        owner: Widget
        picker: object
        pickerAlignElement: string
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        step: string
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggers: object
        value: string|Date
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class TimeField extends PickerField {
        format: string
        max: string|Date
        min: string|Date
        step: string|number|object
        constructor(config?: Partial<TimeFieldConfig>);
        focusPicker(): void;
        showPicker(): void;
    }

    type ToastConfig = {
        color: string
        showProgress: boolean
        timeout: number
    }

    export class Toast {
        constructor(config?: Partial<ToastConfig>);
        static hideAll(): void;
        static show(config: string|object): Toast;
        hide(): void;
    }

    type ToolConfig = {
        adopt: HTMLElement|string
        align: string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        handler: Function
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        repeat: object
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class Tool extends Widget {
        constructor(config?: Partial<ToolConfig>);
    }

    type ToolbarConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        overflow: string|object|null
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        weight: number
        widgetCls: string
        width: string|number
        x: number
        y: number
    }

    export class Toolbar extends Container {
        constructor(config?: Partial<ToolbarConfig>);
    }

    type TooltipConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        allowOver: boolean
        anchor: boolean
        anchorToTarget: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoShow: boolean
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dismissDelay: number
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        forSelector: string
        getHtml: Function
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideDelay: number
        hideOnDelegateChange: boolean
        hideWhenEmpty: boolean
        hoverDelay: number
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        loadingMsg: string
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maximizable: boolean
        maximized: boolean
        minHeight: string|number
        minWidth: string|number
        modal: boolean
        monitorResize: boolean
        mouseOffsetX: number
        mouseOffsetY: number
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showOnClick: boolean
        showOnHover: boolean
        strips: object
        style: string
        tab: boolean|object
        tag: string
        tbar: object[]|object
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        trapFocus: boolean
        weight: number
        width: string|number
        x: number
        y: number
        onBeforeShow: Function
        onPointerOver: Function
    }

    export class Tooltip extends Popup {
        static currentOverElement: HTMLElement
        activeTarget: HTMLElement
        html: string
        triggeredByEvent: Event
        onBeforeShow: Function
        onPointerOver: Function
        constructor(config?: Partial<TooltipConfig>);
        showAsyncMessage(message: string): void;
    }

    type WidgetConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
        onBeforeDestroy: Function
        onBeforeHide: Function
        onBeforeShow: Function
        onCatchAll: Function
        onDestroy: Function
        onFocusIn: Function
        onFocusOut: Function
        onHide: Function
        onPaint: Function
        onReadOnly: Function
        onResize: Function
        onShow: Function
    }

    export class Widget extends Base implements Events, Localizable {
        static $name: string
        alignSelf: string
        anchorSize: number[]
        content: string
        contentElement: HTMLElement
        dataset: object
        disabled: boolean
        element: HTMLElement
        flex: number|string
        focusElement: HTMLElement
        height: number|string
        hidden: boolean
        html: string
        id: string
        isVisible: boolean
        localeManager: typeof LocaleManager
        margin: number|string
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        nextSibling: Widget
        overflowElement: HTMLElement
        owner: Widget
        previousSibling: Widget
        readOnly: boolean
        scrollable: Scroller
        style: string|object|CSSStyleDeclaration
        tab: Tab
        tooltip: string|object
        width: number|string
        x: number
        y: number
        onBeforeDestroy: Function
        onBeforeHide: Function
        onBeforeShow: Function
        onCatchAll: Function
        onDestroy: Function
        onFocusIn: Function
        onFocusOut: Function
        onHide: Function
        onPaint: Function
        onReadOnly: Function
        onResize: Function
        onShow: Function
        constructor(config?: Partial<WidgetConfig>);
        static attachTooltip(element: HTMLElement, configOrText: object|string): HTMLElement;
        static fromElement(element: HTMLElement|Event, type?: string|Function, limit?: HTMLElement|number): Widget;
        static initClass(): void;
        static optionalL(text: string, templateData?: object): string;
        static query(selector: string|Function, deep?: boolean): Widget;
        static queryAll(selector: string|Function, deep?: boolean): Widget[];
        L(text: string, templateData?: object): string;
        addListener(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        alignTo(spec?: object): void;
        closest(selector: string|Function, deep?: boolean, limit?: number|string|Widget): void;
        compose(): object;
        contains(elementOrWidget: HTMLElement|Widget, strict?: boolean): boolean;
        disable(): void;
        eachAncestor(fn: Function): boolean;
        eachWidget(fn: Function, deep?: boolean): boolean;
        enable(): void;
        exitFullscreen(): Promise<any>;
        focus(): void;
        hasListener(eventName: string): boolean;
        hide(animate?: boolean): Promise<any>;
        mask(msg: string|object): Mask;
        on(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        owns(target: HTMLElement|Event|Widget): void;
        recompose(): void;
        relayAll(through: Events, prefix: string, transformCase?: boolean): void;
        removeAllListeners(): void;
        removeListener(config: object, thisObj: object): void;
        requestFullscreen(): Promise<any>;
        resumeEvents(): void;
        revertFocus(force?: boolean): void;
        setXY(x?: number, y?: number): void;
        show(): Promise<any>;
        showBy(spec: object|HTMLElement): Promise<any>;
        showByPoint(x: number|number[], y?: number, options?: object): Promise<any>;
        suspendEvents(queue?: boolean): void;
        toFront(): void;
        trigger(eventName: string, param?: object): boolean|Promise<any>;
        un(config: object, thisObj?: object): void;
        unmask(): void;
        up(selector: string|Function, deep?: boolean, limit?: number|string|Widget): void;
        updateLocalization(): void;
    }

    type UndoRedoBaseConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        color: string
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showZeroActionBadge: boolean
        style: string
        tab: boolean|object
        tag: string
        text: boolean
        textAlign: string
        textContent: boolean
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export abstract class UndoRedoBase extends Container {
        constructor(config?: Partial<UndoRedoBaseConfig>);
    }

    type HistogramConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        data: object[]
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        getBarText: Function
        getBarTip: Function
        getRectClass: Function
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        omitZeroHeightBars: number
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        series: object[]
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        topValue: number
        values: number[]
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class Histogram extends Widget {
        constructor(config?: Partial<HistogramConfig>);
    }

    type ScaleConfig = {
        adopt: HTMLElement|string
        align: string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        horizontal: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class Scale extends Widget {
        constructor(config?: Partial<ScaleConfig>);
    }

    type LayoutConfig = {
        containerCls: string
        itemCls: string
    }

    export class Layout {
        owner: Widget
        constructor(config?: Partial<LayoutConfig>);
    }

    type BadgeConfig = {
        badge: string
    }

    export class Badge {
        badge: string
        constructor(config?: Partial<BadgeConfig>);
    }

    type ResponsiveConfig = {
        breakpoints: object
        onResponsiveHeightChange: Function
        onResponsiveWidthChange: Function
    }

    export class Responsive {
        onResponsiveHeightChange: Function
        onResponsiveWidthChange: Function
        constructor(config?: Partial<ResponsiveConfig>);
    }

    type StyleableConfig = {
        css: object
        cssVarPrefix: string
    }

    export class Styleable {
        css: typeof Proxy
        constructor(config?: Partial<StyleableConfig>);
    }

    type AddNewColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class AddNewColumn extends Column {
        combo: Combo
        constructor(config?: Partial<AddNewColumnConfig>);
    }

    type CalendarColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class CalendarColumn extends Column {
        constructor(config?: Partial<CalendarColumnConfig>);
    }

    type ConstraintDateColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        format: string
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        step: string|number|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class ConstraintDateColumn extends GanttDateColumn {
        constructor(config?: Partial<ConstraintDateColumnConfig>);
    }

    type ConstraintTypeColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class ConstraintTypeColumn extends Column {
        constructor(config?: Partial<ConstraintTypeColumnConfig>);
    }

    type DeadlineDateColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        format: string
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        step: string|number|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class DeadlineDateColumn extends GanttDateColumn {
        constructor(config?: Partial<DeadlineDateColumnConfig>);
    }

    type DependencyColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        delimiter: string
        dependencyIdField: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class DependencyColumn extends Column {
        constructor(config?: Partial<DependencyColumnConfig>);
    }

    type EarlyEndDateColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        format: string
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        step: string|number|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class EarlyEndDateColumn extends GanttDateColumn {
        constructor(config?: Partial<EarlyEndDateColumnConfig>);
    }

    type EarlyStartDateColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        format: string
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        step: string|number|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class EarlyStartDateColumn extends GanttDateColumn {
        constructor(config?: Partial<EarlyStartDateColumnConfig>);
    }

    type EffortColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        decimalPrecision: number|boolean
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        format: string|object|NumberFormat|Partial<NumberFormatConfig>
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        largeStep: number
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        max: number
        min: number
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        step: number
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        unit: string
        width: number|string
    }

    export class EffortColumn extends DurationColumn {
        constructor(config?: Partial<EffortColumnConfig>);
    }

    type EndDateColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        format: string
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        step: string|number|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class EndDateColumn extends GanttDateColumn {
        constructor(config?: Partial<EndDateColumnConfig>);
    }

    type GanttDateColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        format: string
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        step: string|number|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export abstract class GanttDateColumn extends DateColumn {
        constructor(config?: Partial<GanttDateColumnConfig>);
    }

    type LateEndDateColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        format: string
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        step: string|number|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class LateEndDateColumn extends GanttDateColumn {
        constructor(config?: Partial<LateEndDateColumnConfig>);
    }

    type LateStartDateColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        format: string
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        step: string|number|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class LateStartDateColumn extends GanttDateColumn {
        constructor(config?: Partial<LateStartDateColumnConfig>);
    }

    type MilestoneColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        checkCls: string
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showCheckAll: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        widgets: object[]
        width: number|string
    }

    export class MilestoneColumn extends CheckColumn {
        constructor(config?: Partial<MilestoneColumnConfig>);
    }

    type NameColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        collapseIconCls: string
        collapsedFolderIconCls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        expandIconCls: string
        expandedFolderIconCls: string
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        indentSize: number
        instantUpdate: boolean
        invalidAction: string
        leafIconCls: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class NameColumn extends TreeColumn {
        constructor(config?: Partial<NameColumnConfig>);
    }

    type NoteColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class NoteColumn extends Column {
        constructor(config?: Partial<NoteColumnConfig>);
    }

    type PercentDoneColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        format: string|object|NumberFormat|Partial<NumberFormatConfig>
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        largeStep: number
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        max: number
        min: number
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showCircle: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        step: number
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        unit: string
        width: number|string
    }

    export class PercentDoneColumn extends NumberColumn {
        constructor(config?: Partial<PercentDoneColumnConfig>);
    }

    type PredecessorColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        delimiter: string
        dependencyIdField: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class PredecessorColumn extends DependencyColumn {
        constructor(config?: Partial<PredecessorColumnConfig>);
    }

    type ResourceAssignmentColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        itemTpl: Function
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showAvatars: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class ResourceAssignmentColumn extends Column {
        constructor(config?: Partial<ResourceAssignmentColumnConfig>);
    }

    type RollupColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        checkCls: string
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showCheckAll: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        widgets: object[]
        width: number|string
    }

    export class RollupColumn extends CheckColumn {
        constructor(config?: Partial<RollupColumnConfig>);
    }

    type SchedulingModeColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class SchedulingModeColumn extends Column {
        constructor(config?: Partial<SchedulingModeColumnConfig>);
    }

    type SequenceColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class SequenceColumn extends Column {
        constructor(config?: Partial<SequenceColumnConfig>);
    }

    type ShowInTimelineColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        checkCls: string
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showCheckAll: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        widgets: object[]
        width: number|string
    }

    export class ShowInTimelineColumn extends CheckColumn {
        constructor(config?: Partial<ShowInTimelineColumnConfig>);
    }

    type StartDateColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        format: string
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        step: string|number|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class StartDateColumn extends GanttDateColumn {
        constructor(config?: Partial<StartDateColumnConfig>);
    }

    type SuccessorColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        delimiter: string
        dependencyIdField: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class SuccessorColumn extends DependencyColumn {
        constructor(config?: Partial<SuccessorColumnConfig>);
    }

    type TimeAxisColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class TimeAxisColumn extends SchedulerTimeAxisColumn {
        constructor(config?: Partial<TimeAxisColumnConfig>);
    }

    type TotalSlackColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        decimalPrecision: number|boolean
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        format: string|object|NumberFormat|Partial<NumberFormatConfig>
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        largeStep: number
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        max: number
        min: number
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        step: number
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        unit: string
        width: number|string
    }

    export class TotalSlackColumn extends DurationColumn {
        constructor(config?: Partial<TotalSlackColumnConfig>);
    }

    type WBSColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class WBSColumn extends Column {
        constructor(config?: Partial<WBSColumnConfig>);
    }

    type GanttTagConfig = {
        faPath: string
        stylesheet: string
    }

    export class GanttTag extends TimelineBaseTag {
        constructor(config?: Partial<GanttTagConfig>);
    }

    type AssignmentStoreConfig = {
        allowNoId: boolean
        autoCommit: boolean
        autoLoad: boolean
        autoTree: boolean
        bubbleEvents: object
        chainedFields: string[]
        chainedFilterFn: Function
        createUrl: string
        data: object[]|Model[]|Partial<ModelConfig>[]
        deleteUrl: string
        doRelayToMaster: string[]
        dontRelayToMaster: string
        fetchOptions: object
        fields: string[]|object[]|DataField[]|Partial<DataFieldConfig>[]
        filterParamName: string
        filters: object|object[]
        groupers: object[]
        headers: object
        httpMethods: object
        id: string|number
        keepUncommittedChanges: boolean
        listeners: object
        masterStore: Store
        modelClass: typeof Model
        pageParamName: string
        pageSize: number
        pageSizeParamName: string
        pageStartParamName: string
        params: object
        parentIdParamName: string
        readUrl: string
        reapplyFilterOnAdd: boolean
        reapplyFilterOnUpdate: boolean
        reapplySortersOnAdd: boolean
        responseDataProperty: string
        responseSuccessProperty: string
        responseTotalProperty: string
        restfulFilter: boolean
        sendAsFormData: boolean
        sortParamName: string
        sorters: object[]|string[]
        stm: StateTrackingManager
        storage: Collection|object|Partial<CollectionConfig>
        syncDataOnLoad: boolean|object
        taskStore: EventStore|object|Partial<EventStoreConfig>
        transformFlatData: boolean
        tree: boolean
        updateUrl: string
        useLocaleSort: boolean|string|object
        useRawData: boolean|object
        useRestfulMethods: boolean
        writeAllFields: boolean
    }

    export class AssignmentStore extends SchedulerProAssignmentStore {
        constructor(config?: Partial<AssignmentStoreConfig>);
    }

    type CalendarManagerStoreConfig = {
        allowNoId: boolean
        autoCommit: boolean
        autoLoad: boolean
        autoTree: boolean
        bubbleEvents: object
        chainedFields: string[]
        chainedFilterFn: Function
        createUrl: string
        data: object[]|Model[]|Partial<ModelConfig>[]
        deleteUrl: string
        doRelayToMaster: string[]
        dontRelayToMaster: string
        fetchOptions: object
        fields: string[]|object[]|DataField[]|Partial<DataFieldConfig>[]
        filterParamName: string
        filters: object|object[]
        groupers: object[]
        headers: object
        httpMethods: object
        id: string|number
        keepUncommittedChanges: boolean
        listeners: object
        masterStore: Store
        modelClass: typeof Model
        pageParamName: string
        pageSize: number
        pageSizeParamName: string
        pageStartParamName: string
        params: object
        parentIdParamName: string
        readUrl: string
        reapplyFilterOnAdd: boolean
        reapplyFilterOnUpdate: boolean
        reapplySortersOnAdd: boolean
        responseDataProperty: string
        responseSuccessProperty: string
        responseTotalProperty: string
        restfulFilter: boolean
        sendAsFormData: boolean
        sortParamName: string
        sorters: object[]|string[]
        stm: StateTrackingManager
        storage: Collection|object|Partial<CollectionConfig>
        syncDataOnLoad: boolean|object
        taskStore: EventStore|object|Partial<EventStoreConfig>
        transformFlatData: boolean
        tree: boolean
        updateUrl: string
        useLocaleSort: boolean|string|object
        useRawData: boolean|object
        useRestfulMethods: boolean
        writeAllFields: boolean
    }

    export class CalendarManagerStore extends SchedulerProCalendarManagerStore {
        constructor(config?: Partial<CalendarManagerStoreConfig>);
    }

    type DependencyStoreConfig = {
        allowNoId: boolean
        autoCommit: boolean
        autoLoad: boolean
        autoTree: boolean
        bubbleEvents: object
        chainedFields: string[]
        chainedFilterFn: Function
        createUrl: string
        data: object[]|Model[]|Partial<ModelConfig>[]
        deleteUrl: string
        doRelayToMaster: string[]
        dontRelayToMaster: string
        fetchOptions: object
        fields: string[]|object[]|DataField[]|Partial<DataFieldConfig>[]
        filterParamName: string
        filters: object|object[]
        groupers: object[]
        headers: object
        httpMethods: object
        id: string|number
        keepUncommittedChanges: boolean
        listeners: object
        masterStore: Store
        modelClass: typeof Model
        pageParamName: string
        pageSize: number
        pageSizeParamName: string
        pageStartParamName: string
        params: object
        parentIdParamName: string
        readUrl: string
        reapplyFilterOnAdd: boolean
        reapplyFilterOnUpdate: boolean
        reapplySortersOnAdd: boolean
        responseDataProperty: string
        responseSuccessProperty: string
        responseTotalProperty: string
        restfulFilter: boolean
        sendAsFormData: boolean
        sortParamName: string
        sorters: object[]|string[]
        stm: StateTrackingManager
        storage: Collection|object|Partial<CollectionConfig>
        syncDataOnLoad: boolean|object
        taskStore: EventStore|object|Partial<EventStoreConfig>
        transformFlatData: boolean
        tree: boolean
        updateUrl: string
        useLocaleSort: boolean|string|object
        useRawData: boolean|object
        useRestfulMethods: boolean
        writeAllFields: boolean
    }

    export class DependencyStore extends SchedulerProDependencyStore {
        constructor(config?: Partial<DependencyStoreConfig>);
    }

    type ResourceStoreConfig = {
        allowNoId: boolean
        autoCommit: boolean
        autoLoad: boolean
        autoTree: boolean
        bubbleEvents: object
        chainedFields: string[]
        chainedFilterFn: Function
        createUrl: string
        data: object[]|Model[]|Partial<ModelConfig>[]
        deleteUrl: string
        doRelayToMaster: string[]
        dontRelayToMaster: string
        fetchOptions: object
        fields: string[]|object[]|DataField[]|Partial<DataFieldConfig>[]
        filterParamName: string
        filters: object|object[]
        groupers: object[]
        headers: object
        httpMethods: object
        id: string|number
        keepUncommittedChanges: boolean
        listeners: object
        masterStore: Store
        modelClass: typeof Model
        pageParamName: string
        pageSize: number
        pageSizeParamName: string
        pageStartParamName: string
        params: object
        parentIdParamName: string
        readUrl: string
        reapplyFilterOnAdd: boolean
        reapplyFilterOnUpdate: boolean
        reapplySortersOnAdd: boolean
        responseDataProperty: string
        responseSuccessProperty: string
        responseTotalProperty: string
        restfulFilter: boolean
        sendAsFormData: boolean
        sortParamName: string
        sorters: object[]|string[]
        stm: StateTrackingManager
        storage: Collection|object|Partial<CollectionConfig>
        syncDataOnLoad: boolean|object
        taskStore: EventStore|object|Partial<EventStoreConfig>
        transformFlatData: boolean
        tree: boolean
        updateUrl: string
        useLocaleSort: boolean|string|object
        useRawData: boolean|object
        useRestfulMethods: boolean
        writeAllFields: boolean
    }

    export class ResourceStore extends SchedulerProResourceStore {
        constructor(config?: Partial<ResourceStoreConfig>);
    }

    type TaskStoreConfig = {
        allowNoId: boolean
        autoCommit: boolean
        autoLoad: boolean
        autoTree: boolean
        bubbleEvents: object
        chainedFields: string[]
        chainedFilterFn: Function
        createUrl: string
        data: object[]|Model[]|Partial<ModelConfig>[]
        deleteUrl: string
        doRelayToMaster: string[]
        dontRelayToMaster: string
        fetchOptions: object
        fields: string[]|object[]|DataField[]|Partial<DataFieldConfig>[]
        filterParamName: string
        filters: object|object[]
        groupers: object[]
        headers: object
        httpMethods: object
        id: string|number
        keepUncommittedChanges: boolean
        listeners: object
        masterStore: Store
        modelClass: typeof Model
        pageParamName: string
        pageSize: number
        pageSizeParamName: string
        pageStartParamName: string
        params: object
        parentIdParamName: string
        readUrl: string
        reapplyFilterOnAdd: boolean
        reapplyFilterOnUpdate: boolean
        reapplySortersOnAdd: boolean
        responseDataProperty: string
        responseSuccessProperty: string
        responseTotalProperty: string
        restfulFilter: boolean
        sendAsFormData: boolean
        sortParamName: string
        sorters: object[]|string[]
        stm: StateTrackingManager
        storage: Collection|object|Partial<CollectionConfig>
        syncDataOnLoad: boolean|object
        transformFlatData: boolean
        tree: boolean
        updateUrl: string
        useLocaleSort: boolean|string|object
        useRawData: boolean|object
        useRestfulMethods: boolean
        writeAllFields: boolean
        onBeforeIndent: Function
        onBeforeOutdent: Function
        onIndent: Function
        onOutdent: Function
    }

    export class TaskStore extends AjaxStore {
        onBeforeIndent: Function
        onBeforeOutdent: Function
        onIndent: Function
        onOutdent: Function
        constructor(config?: Partial<TaskStoreConfig>);
        indent(nodes: TaskModel|TaskModel[]): Promise<any>;
        isDateRangeAvailable(start: Date, end: Date, excludeEvent: SchedulerEventModel|null, resource: SchedulerResourceModel): boolean;
        outdent(nodes: TaskModel|TaskModel[]): Promise<any>;
        setBaseline(index: number): void;
    }

    export class Wbs {
        value: string
        static compare(lhs: string|Wbs, rhs: string|Wbs): number;
        static from(value: string|number|Wbs): Wbs;
        append(value: string|number): Wbs;
        isEqual(value: string|Wbs): boolean;
        match(pattern: string): boolean;
    }

    type WbsFieldConfig = {
        alwaysWrite: boolean
        column: string|object
        compare: Function
        dataSource: string
        defaultValue: any
        internal: boolean
        label: string
        name: string
        nullText: string
        nullValue: any
        nullable: boolean
        persist: boolean
        readOnly: boolean
    }

    export class WbsField extends DataField {
        constructor(config?: Partial<WbsFieldConfig>);
    }

    type BaselinesConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        allowOver: boolean
        anchor: boolean
        anchorToTarget: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoShow: boolean
        autoUpdate: boolean
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dismissDelay: number
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        forSelector: string
        getHtml: Function
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideDelay: number
        hideOnDelegateChange: boolean
        hideWhenEmpty: boolean
        hoverDelay: number
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        loadingMsg: string
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maximizable: boolean
        maximized: boolean
        minHeight: string|number
        minWidth: string|number
        modal: boolean
        monitorResize: boolean
        mouseOffsetX: number
        mouseOffsetY: number
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showOnClick: boolean
        showOnHover: boolean
        strips: object
        style: string
        tab: boolean|object
        tag: string
        tbar: object[]|object
        template: Function
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        trapFocus: boolean
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class Baselines extends TooltipBase {
        constructor(config?: Partial<BaselinesConfig>);
    }

    type CellEditConfig = {
        addNewAtEnd: boolean|object
        autoEdit: boolean
        autoSelect: boolean
        blurAction: string
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        triggerEvent: string
    }

    export class CellEdit extends GridCellEdit {
        constructor(config?: Partial<CellEditConfig>);
        doAddNewAtEnd(): Promise<any>;
    }

    type CriticalPathsConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        onCriticalPathsHighlighted: Function
        onCriticalPathsUnhighlighted: Function
    }

    export class CriticalPaths extends InstancePlugin {
        onCriticalPathsHighlighted: Function
        onCriticalPathsUnhighlighted: Function
        constructor(config?: Partial<CriticalPathsConfig>);
    }

    type DependenciesConfig = {
        allowCreate: boolean
        allowDropOnEventBar: boolean
        bubbleEvents: object
        creationTooltip: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        pathFinderConfig: object
        showCreationTooltip: boolean
        showTooltip: boolean
        terminalCls: string
        terminalSides: string[]
        tooltip: object
    }

    export class Dependencies extends SchedulerDependencies {
        constructor(config?: Partial<DependenciesConfig>);
        drawForTask(): void;
        resolveDependencyRecord(element: HTMLElement): DependencyModel;
    }

    type DependencyEditConfig = {
        autoClose: boolean
        bubbleEvents: object
        disabled: boolean
        editorConfig: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        saveAndCloseOnEnter: boolean
        showDeleteButton: boolean
        showLagField: boolean
        triggerEvent: string
    }

    export class DependencyEdit extends SchedulerDependencyEdit {
        constructor(config?: Partial<DependencyEditConfig>);
    }

    type IndicatorsConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        allowOver: boolean
        anchor: boolean
        anchorToTarget: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoShow: boolean
        autoUpdate: boolean
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dismissDelay: number
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        forSelector: string
        getHtml: Function
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideDelay: number
        hideOnDelegateChange: boolean
        hideWhenEmpty: boolean
        hoverDelay: number
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        loadingMsg: string
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maximizable: boolean
        maximized: boolean
        minHeight: string|number
        minWidth: string|number
        modal: boolean
        monitorResize: boolean
        mouseOffsetX: number
        mouseOffsetY: number
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showOnClick: boolean
        showOnHover: boolean
        strips: object
        style: string
        tab: boolean|object
        tag: string
        tbar: object[]|object
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        tooltipTemplate: Function
        trapFocus: boolean
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class Indicators extends TooltipBase {
        constructor(config?: Partial<IndicatorsConfig>);
    }

    type LabelsConfig = {
        blurAction: string
        bottom: object
        bubbleEvents: object
        disabled: boolean
        labelCharWidth: number
        labelCls: string
        labelLayoutMode: string
        left: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        right: object
        top: object
    }

    export class Labels extends SchedulerLabels {
        constructor(config?: Partial<LabelsConfig>);
    }

    type ProgressLineConfig = {
        bubbleEvents: object
        disabled: boolean
        drawLineOnlyWhenStatusDateVisible: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        statusDate: Date
        onProgressLineDrawn: Function
    }

    export class ProgressLine extends InstancePlugin implements Delayable {
        statusDate: Date
        onProgressLineDrawn: Function
        constructor(config?: Partial<ProgressLineConfig>);
        draw(): void;
        shouldDrawProgressLine(): boolean;
    }

    type ProjectLinesConfig = {
        bubbleEvents: object
        currentDateFormat: string
        currentTimeLineUpdateInterval: number
        disabled: boolean
        enableResizing: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        showCurrentTimeLine: boolean|object
        showHeaderElements: boolean
        showTooltip: boolean|object
        store: object|Store|Partial<StoreConfig>
        timeRanges: TimeSpan[]|object[]|Partial<TimeSpanConfig>[]
        tooltipTemplate: Function
    }

    export class ProjectLines extends TimeRanges {
        constructor(config?: Partial<ProjectLinesConfig>);
    }

    type RollupsConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        allowOver: boolean
        anchor: boolean
        anchorToTarget: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoShow: boolean
        autoUpdate: boolean
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dismissDelay: number
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        forSelector: string
        getHtml: Function
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideDelay: number
        hideOnDelegateChange: boolean
        hideWhenEmpty: boolean
        hoverDelay: number
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        loadingMsg: string
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maximizable: boolean
        maximized: boolean
        minHeight: string|number
        minWidth: string|number
        modal: boolean
        monitorResize: boolean
        mouseOffsetX: number
        mouseOffsetY: number
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showOnClick: boolean
        showOnHover: boolean
        strips: object
        style: string
        tab: boolean|object
        tag: string
        tbar: object[]|object
        template: Function
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        trapFocus: boolean
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class Rollups extends TooltipBase {
        constructor(config?: Partial<RollupsConfig>);
    }

    type TaskContextMenuConfig = {
        bubbleEvents: object
        disabled: boolean
        items: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        menu: object
        menuConfig: object
        processItems: Function
        triggerEvent: string
        type: string
        onTaskContextMenuBeforeShow: Function
        onTaskContextMenuItem: Function
        onTaskContextMenuShow: Function
    }

    export class TaskContextMenu extends TaskMenu {
        onTaskContextMenuBeforeShow: Function
        onTaskContextMenuItem: Function
        onTaskContextMenuShow: Function
        constructor(config?: Partial<TaskContextMenuConfig>);
        showContextMenuFor(taskRecord: TaskModel, options?: object): void;
    }

    type TaskCopyPasteConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        nameField: string
    }

    export class TaskCopyPaste extends RowCopyPaste {
        constructor(config?: Partial<TaskCopyPasteConfig>);
    }

    type TaskDragConfig = {
        bubbleEvents: object
        constrainDragToTimeline: boolean
        disabled: boolean
        dragHelperConfig: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        showExactDropPosition: boolean
        showTooltip: boolean
        tooltipTemplate: Function
        validatorFn: Function
        validatorFnThisObj: object
        onAfterTaskDrop: Function
        onBeforeTaskDrag: Function
        onBeforeTaskDropFinalize: Function
        onTaskDrag: Function
        onTaskDragStart: Function
        onTaskDrop: Function
    }

    export class TaskDrag extends DragBase {
        onAfterTaskDrop: Function
        onBeforeTaskDrag: Function
        onBeforeTaskDropFinalize: Function
        onTaskDrag: Function
        onTaskDragStart: Function
        onTaskDrop: Function
        constructor(config?: Partial<TaskDragConfig>);
    }

    type TaskDragCreateConfig = {
        bubbleEvents: object
        disabled: boolean
        dragTolerance: number
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        showTooltip: boolean
        validatorFnThisObj: object
        onAfterDragCreate: Function
        onBeforeDragCreate: Function
        onBeforeDragCreateFinalize: Function
        onDragCreateEnd: Function
        onDragCreateStart: Function
    }

    export class TaskDragCreate extends DragCreateBase {
        onAfterDragCreate: Function
        onBeforeDragCreate: Function
        onBeforeDragCreateFinalize: Function
        onDragCreateEnd: Function
        onDragCreateStart: Function
        constructor(config?: Partial<TaskDragCreateConfig>);
    }

    type TaskEditConfig = {
        bubbleEvents: object
        confirmDelete: boolean
        disabled: boolean
        editorClass: Widget
        editorConfig: object
        items: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        saveAndCloseOnEnter: boolean
        scrollIntoView: boolean
        showDeleteButton: boolean
        tabsConfig: object
        triggerEvent: string
        weekStartDay: number
    }

    export class TaskEdit extends SchedulerProTaskEdit {
        constructor(config?: Partial<TaskEditConfig>);
        editTask(taskRecord: TaskModel, element?: HTMLElement): Promise<any>;
    }

    type TaskMenuConfig = {
        bubbleEvents: object
        disabled: boolean
        items: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        menu: object
        menuConfig: object
        processItems: Function
        triggerEvent: string
        type: string
        onTaskMenuBeforeShow: Function
        onTaskMenuItem: Function
        onTaskMenuShow: Function
    }

    export class TaskMenu extends EventMenu {
        onTaskMenuBeforeShow: Function
        onTaskMenuItem: Function
        onTaskMenuShow: Function
        constructor(config?: Partial<TaskMenuConfig>);
    }

    type TaskResizeConfig = {
        allowResizeToZero: boolean
        bottomHandle: boolean
        bubbleEvents: object
        disabled: boolean
        dragThreshold: number
        dynamicHandleSize: boolean
        handleSize: number
        leftHandle: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        reservedSpace: number
        rightHandle: boolean
        showExactResizePosition: boolean
        tip: Tooltip|object|Partial<TooltipConfig>
        tooltipTemplate: Function
        topHandle: boolean
        touchHandleSize: number
        validatorFn: Function
        validatorFnThisObj: object
        onBeforeTaskResize: Function
        onBeforeTaskResizeFinalize: Function
        onTaskPartialResize: Function
        onTaskResizeEnd: Function
        onTaskResizeStart: Function
    }

    export class TaskResize extends SchedulerEventResize {
        onBeforeTaskResize: Function
        onBeforeTaskResizeFinalize: Function
        onTaskPartialResize: Function
        onTaskResizeEnd: Function
        onTaskResizeStart: Function
        constructor(config?: Partial<TaskResizeConfig>);
    }

    type TaskTooltipConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        allowOver: boolean
        anchor: boolean
        anchorToTarget: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoShow: boolean
        autoUpdate: boolean
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        decimalPrecision: number|boolean
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dismissDelay: number
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        forSelector: string
        getHtml: Function
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideDelay: number
        hideOnDelegateChange: boolean
        hideWhenEmpty: boolean
        hoverDelay: number
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        loadingMsg: string
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maximizable: boolean
        maximized: boolean
        minHeight: string|number
        minWidth: string|number
        modal: boolean
        monitorResize: boolean
        mouseOffsetX: number
        mouseOffsetY: number
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showOnClick: boolean
        showOnHover: boolean
        strips: object
        style: string
        tab: boolean|object
        tag: string
        tbar: object[]|object
        template: Function
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        trapFocus: boolean
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class TaskTooltip extends TooltipBase {
        constructor(config?: Partial<TaskTooltipConfig>);
    }

    type MspExportConfig = {
        bubbleEvents: object
        dateFormat: string
        disabled: boolean
        filename: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        msProjectVersion: number
        timeFormat: string
    }

    export class MspExport extends InstancePlugin {
        constructor(config?: Partial<MspExportConfig>);
        export(config?: object): void;
    }

    type PdfExportConfig = {
        alignRows: boolean
        bubbleEvents: object
        clientURL: string
        disabled: boolean
        exportDialog: object
        exportMask: string
        exportProgressMask: string
        exportServer: string
        exporterType: string
        exporters: Exporter[]
        fetchOptions: object
        fileFormat: string
        fileName: string
        footerTpl: Function
        headerTpl: Function
        keepPathName: boolean
        keepRegionSizes: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        openAfterExport: boolean
        openInNewTab: boolean
        orientation: string
        paperFormat: string
        rangeEnd: Date
        rangeStart: Date
        repeatHeader: boolean
        rowsRange: string
        scheduleRange: string
        sendAsBinary: boolean
        showErrorToast: boolean
        translateURLsToAbsolute: boolean|string
    }

    export class PdfExport extends SchedulerPdfExport {
        constructor(config?: Partial<PdfExportConfig>);
    }

    type AssignmentModelConfig = {
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        drawDependencies: boolean
        event: string|number
        eventId: string|number
        id: string|number
        parentId: string|number|null
        parentIndex: number
        resource: string|number
        resourceId: string|number
        units: number
    }

    export class AssignmentModel extends SchedulerProAssignmentModel {
        event: string|number
        resource: string|number
        units: number
        constructor(config?: Partial<AssignmentModelConfig>);
    }

    type BaselineConfig = {
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: DomClassList|string
        duration: number
        durationUnit: string
        endDate: string|Date
        iconCls: string
        id: string|number
        name: string
        parentId: string|number|null
        parentIndex: number
        startDate: string|Date
        style: string
        task: TaskModel
    }

    export class Baseline extends TimeSpan {
        task: TaskModel
        constructor(config?: Partial<BaselineConfig>);
        convertToMilestone(): void;
        convertToRegular(): void;
    }

    type CalendarIntervalModelConfig = {
        endDate: Date
        isWorking: boolean
        recurrentEndDate: string
        recurrentStartDate: string
        startDate: Date
    }

    export class CalendarIntervalModel extends SchedulerProCalendarIntervalModel {
        constructor(config?: Partial<CalendarIntervalModelConfig>);
    }

    type CalendarModelConfig = {
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        id: string|number
        intervals: SchedulerProCalendarIntervalModel[]
        name: string
        parentId: string|number|null
        parentIndex: number
        taskStore: EventStore|object|Partial<EventStoreConfig>
        unspecifiedTimeIsWorking: boolean
    }

    export class CalendarModel extends SchedulerProCalendarModel {
        constructor(config?: Partial<CalendarModelConfig>);
    }

    type DependencyModelConfig = {
        active: boolean
        bidirectional: boolean
        calendar: SchedulerProCalendarModel
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        from: string|number
        fromEvent: string|number|SchedulerEventModel
        fromSide: string
        fromTask: string|number|TaskModel
        id: string|number
        lag: number
        lagUnit: string
        parentId: string|number|null
        parentIndex: number
        taskStore: EventStore|object|Partial<EventStoreConfig>
        to: string|number
        toEvent: string|number|SchedulerEventModel
        toSide: string
        toTask: string|number|TaskModel
        type: number
    }

    export class DependencyModel extends SchedulerProDependencyModel {
        fromTask: string|number|TaskModel
        toTask: string|number|TaskModel
        constructor(config?: Partial<DependencyModelConfig>);
    }

    type ProjectModelConfig = {
        adjustDurationToDST: boolean
        assignmentModelClass: AssignmentModel
        assignmentStore: AssignmentStore|object|Partial<AssignmentStoreConfig>
        assignmentStoreClass: AssignmentStore
        assignmentsData: object[]|AssignmentModel[]|Partial<AssignmentModelConfig>[]
        autoLoad: boolean
        autoSync: boolean
        autoSyncTimeout: number
        bubbleEvents: object
        calendar: string|object|CalendarModel|Partial<CalendarModelConfig>
        calendarManagerStore: CalendarManagerStore|object|Partial<CalendarManagerStoreConfig>
        calendarManagerStoreClass: CalendarManagerStore
        calendarModelClass: CalendarModel
        calendarsData: object[]|CalendarModel[]|Partial<CalendarModelConfig>[]
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        crudStores: Store[]|string[]|object[]|Partial<StoreConfig>[]
        daysPerMonth: number
        daysPerWeek: number
        dependenciesCalendar: string
        dependenciesData: object[]|DependencyModel[]|Partial<DependencyModelConfig>[]
        dependencyModelClass: DependencyModel
        dependencyStore: DependencyStore|object|Partial<DependencyStoreConfig>
        dependencyStoreClass: DependencyStore
        direction: string
        enableProgressNotifications: boolean
        encoder: object
        endDate: string|Date
        eventModelClass: TaskModel
        eventStore: TaskStore|object|Partial<TaskStoreConfig>
        eventStoreClass: TaskStore
        eventsData: object[]|TaskModel[]|Partial<TaskModelConfig>[]
        hoursPerDay: number
        id: string|number
        listeners: object
        parentId: string|number|null
        parentIndex: number
        phantomIdField: string
        phantomParentIdField: string
        project: SchedulerProjectModel
        resetIdsBeforeSync: boolean
        resourceModelClass: ResourceModel
        resourceStore: ResourceStore|object|Partial<ResourceStoreConfig>
        resourceStoreClass: ResourceStore
        resourcesData: object[]|ResourceModel[]|Partial<ResourceModelConfig>[]
        silenceInitialCommit: boolean
        skipSuccessProperty: boolean
        startDate: string|Date
        storeIdProperty: string
        supportShortSyncResponse: boolean
        syncApplySequence: string[]
        taskModelClass: TaskModel
        taskStore: TaskStore|object|Partial<TaskStoreConfig>
        taskStoreClass: TaskStore
        tasksData: object[]|TaskModel[]|Partial<TaskModelConfig>[]
        timeRangeStore: object|Store|Partial<StoreConfig>
        timeRangesData: object[]|TimeSpan[]|Partial<TimeSpanConfig>[]
        trackResponseType: boolean
        transport: object
        validateResponse: boolean
        writeAllFields: boolean
        onBeforeDestroy: Function
        onBeforeLoad: Function
        onBeforeLoadApply: Function
        onBeforeResponseApply: Function
        onBeforeSend: Function
        onBeforeSync: Function
        onBeforeSyncApply: Function
        onCatchAll: Function
        onChange: Function
        onDestroy: Function
        onHasChanges: Function
        onLoad: Function
        onLoadCanceled: Function
        onLoadFail: Function
        onNoChanges: Function
        onProgress: Function
        onRequestDone: Function
        onRequestFail: Function
        onSync: Function
        onSyncCanceled: Function
        onSyncDelayed: Function
        onSyncFail: Function
    }

    export class ProjectModel extends Model implements ProjectCrudManager, Events {
        assignmentStore: AssignmentStore
        calendar: CalendarModel
        calendarManagerStore: CalendarManagerStore
        changes: object
        criticalPaths: any[][]
        crudRevision: number
        crudStores: object[]
        daysPerMonth: number
        daysPerWeek: number
        dependenciesCalendar: string
        dependencyStore: DependencyStore
        direction: string
        enableProgressNotifications: boolean
        endDate: string|Date
        eventStore: TaskStore
        hoursPerDay: number
        inlineData: object
        isCrudManagerLoading: boolean
        isCrudManagerSyncing: boolean
        json: string
        resourceStore: ResourceStore
        startDate: string|Date
        stm: StateTrackingManager
        syncApplySequence: object[]
        taskStore: TaskStore
        timeRangeStore: Store
        onBeforeDestroy: Function
        onBeforeLoad: Function
        onBeforeLoadApply: Function
        onBeforeResponseApply: Function
        onBeforeSend: Function
        onBeforeSync: Function
        onBeforeSyncApply: Function
        onCatchAll: Function
        onChange: Function
        onDestroy: Function
        onHasChanges: Function
        onLoad: Function
        onLoadCanceled: Function
        onLoadFail: Function
        onNoChanges: Function
        onProgress: Function
        onRequestDone: Function
        onRequestFail: Function
        onSync: Function
        onSyncCanceled: Function
        onSyncDelayed: Function
        onSyncFail: Function
        constructor(config?: Partial<ProjectModelConfig>);
        acceptChanges(): void;
        addCrudStore(store: Store|string|object|Store[]|string[]|object[]|Partial<StoreConfig>|Partial<StoreConfig>[], position?: number, fromStore?: string|Store|object|Partial<StoreConfig>): void;
        addListener(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        addStoreToApplySequence(store: Store|object|Store[]|object[]|Partial<StoreConfig>|Partial<StoreConfig>[], position?: number, fromStore?: string|Store|object|Partial<StoreConfig>): void;
        cancelRequest(requestPromise: Promise<any>): void;
        commitAsync(): Promise<any>;
        commitCrudStores(): void;
        crudStoreHasChanges(storeId?: string|Store): boolean;
        decode(responseText: string): object;
        doDestroy(): void;
        encode(requestData: object): string;
        getCalendar(): CalendarModel;
        getCrudStore(storeId: string): Store;
        getStoreDescriptor(storeId: string|Store): object;
        hasListener(eventName: string): boolean;
        load(options?: object): Promise<any>;
        loadCrudManagerData(response: object, options?: object): void;
        loadInlineData(dataPackage: object): void;
        on(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        propagate(): Promise<any>;
        rejectCrudStores(): void;
        relayAll(through: Events, prefix: string, transformCase?: boolean): void;
        removeAllListeners(): void;
        removeCrudStore(store: object|string|Store|Partial<StoreConfig>): void;
        removeListener(config: object, thisObj: object): void;
        removeStoreFromApplySequence(store: object|string|Store|Partial<StoreConfig>): void;
        resumeAutoSync(doSync?: boolean): void;
        resumeEvents(): void;
        resumePropagate(trigger?: boolean): Promise<any>;
        revertChanges(): void;
        sendRequest(request: object): Promise<any>;
        setCalendar(calendar: CalendarModel): Promise<any>;
        suspendAutoSync(): void;
        suspendEvents(queue?: boolean): void;
        suspendPropagate(): void;
        sync(): Promise<any>;
        toJSON(): object;
        trigger(eventName: string, param?: object): boolean|Promise<any>;
        un(config: object, thisObj?: object): void;
    }

    type ResourceModelConfig = {
        barMargin: number
        calendar: SchedulerProCalendarModel
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        eventColor: string
        eventLayout: string
        eventStyle: string
        expanded: boolean
        href: string
        iconCls: string
        id: string|number
        image: string
        imageUrl: string
        name: string
        parentId: string|number|null
        parentIndex: number
        resourceMargin: number
        rowHeight: number
        target: string
    }

    export class ResourceModel extends SchedulerProResourceModel {
        constructor(config?: Partial<ResourceModelConfig>);
    }

    type TaskModelConfig = {
        assigned: Set<any>
        baselines: object[]
        calendar: CalendarModel
        children: boolean|object[]|TaskModel[]|Partial<TaskModelConfig>[]
        cls: DomClassList|string
        constraintDate: string|Date|null
        constraintType: string|null
        critical: boolean
        deadlineDate: string|Date
        draggable: boolean
        duration: number
        durationUnit: string
        earlyEndDate: string|Date
        earlyStartDate: string|Date
        effectiveCalendar: CalendarModel
        effort: number
        effortDriven: boolean
        effortUnit: string
        endDate: string|Date
        expanded: boolean
        iconCls: string
        id: string|number
        lateEndDate: string|Date
        lateStartDate: string|Date
        manuallyScheduled: boolean
        name: string
        note: string
        parentId: string|number|null
        parentIndex: number
        percentDone: number
        resizable: boolean|string
        rollup: boolean
        schedulingMode: string
        showInTimeline: boolean
        slackUnit: string
        startDate: string|Date
        style: string
        taskIconCls: string
        taskStore: EventStore|object|Partial<EventStoreConfig>
        totalSlack: number
        wbsIndex: number[]
        wbsValue: Wbs|string
    }

    export class TaskModel extends TimeSpan implements PartOfProject, PercentDoneMixin {
        static convertEmptyParentToLeaf: boolean|object
        allDependencies: DependencyModel[]
        assigned: Set<any>
        assignmentStore: SchedulerProAssignmentStore
        assignments: AssignmentModel[]
        baselines: object[]
        calendar: CalendarModel
        calendarManagerStore: SchedulerProCalendarManagerStore
        children: boolean|object[]|TaskModel[]|Partial<TaskModelConfig>[]
        cls: DomClassList|string
        constraintDate: string|Date|null
        constraintType: string|null
        critical: boolean
        deadlineDate: string|Date
        dependencyStore: SchedulerProDependencyStore
        draggable: boolean
        duration: number
        durationUnit: string
        earlyEndDate: string|Date
        earlyStartDate: string|Date
        effectiveCalendar: CalendarModel
        effort: number
        effortDriven: boolean
        effortUnit: string
        endDate: string|Date
        eventStore: EventStore
        expanded: boolean
        fullEffort: Duration
        iconCls: string
        id: string|number
        incomingDeps: Set<any>
        isCompleted: boolean
        isInProgress: boolean
        isStarted: boolean
        lateEndDate: string|Date
        lateStartDate: string|Date
        manuallyScheduled: boolean
        name: string
        note: string
        outgoingDeps: Set<any>
        percentDone: number
        predecessorTasks: TaskModel[]
        predecessors: DependencyModel[]
        previousSiblingsTotalCount: number
        project: SchedulerProProjectModel
        renderedPercentDone: number
        resizable: boolean|string
        resourceStore: SchedulerProResourceStore
        resources: ResourceModel[]
        rollup: boolean
        schedulingMode: string
        sequenceNumber: number
        showInTimeline: boolean
        slackUnit: string
        startDate: string|Date
        successorTasks: TaskModel[]
        successors: DependencyModel[]
        taskIconCls: string
        taskStore: EventStore
        totalSlack: number
        wbsIndex: number[]
        wbsValue: Wbs|string
        constructor(config?: Partial<TaskModelConfig>);
        assign(resource: ResourceModel, units?: number): Promise<any>;
        commitAsync(): Promise<any>;
        convertToMilestone(): void;
        convertToRegular(): void;
        getAssignmentFor(resource: ResourceModel): AssignmentModel|null;
        getCalendar(): CalendarModel;
        isEditable(fieldName: string): boolean;
        refreshWbs(options?: object, index?: number): void;
        setBaseline(version: number): void;
        setCalendar(calendar: CalendarModel): Promise<any>;
        setConstraint(constraintType: string, constraintDate?: Date): Promise<any>;
        setDuration(duration: number, unit?: string): Promise<any>;
        setEffort(effort: number, unit?: string): Promise<any>;
        setEndDate(date: Date, keepDuration?: boolean): Promise<any>;
        setStartDate(date: Date, keepDuration?: boolean): Promise<any>;
        unassign(resource: ResourceModel): Promise<any>;
    }

    export class ProjectGenerator {
    }

    type GanttFeaturesType = {
        baselines: Baselines
        cellEdit: CellEdit
        cellMenu: CellMenu
        cellTooltip: CellTooltip
        columnAutoWidth: ColumnAutoWidth
        columnDragToolbar: ColumnDragToolbar
        columnLines: ColumnLines
        columnPicker: ColumnPicker
        columnReorder: ColumnReorder
        columnResize: ColumnResize
        contextMenu: ContextMenu
        criticalPaths: CriticalPaths
        dependencies: Dependencies
        dependencyEdit: DependencyEdit
        eventFilter: EventFilter
        excelExporter: GridExcelExporter
        filter: Filter
        filterBar: FilterBar
        group: Group
        groupSummary: GridGroupSummary
        headerContextMenu: HeaderContextMenu
        headerMenu: HeaderMenu
        headerZoom: HeaderZoom
        indicators: Indicators
        labels: Labels
        mspExport: MspExport
        nonWorkingTime: NonWorkingTime
        pan: Pan
        pdfExport: PdfExport
        percentBar: PercentBar
        progressLine: ProgressLine
        projectLines: ProjectLines
        quickFind: QuickFind
        regionResize: RegionResize
        rollups: Rollups
        rowCopyPaste: RowCopyPaste
        rowReorder: RowReorder
        scheduleMenu: ScheduleMenu
        scheduleTooltip: ScheduleTooltip
        search: Search
        sort: Sort
        stickyCells: StickyCells
        stripe: Stripe
        summary: Summary
        taskContextMenu: TaskContextMenu
        taskCopyPaste: TaskCopyPaste
        taskDrag: TaskDrag
        taskDragCreate: TaskDragCreate
        taskEdit: TaskEdit
        taskMenu: TaskMenu
        taskResize: TaskResize
        taskTooltip: TaskTooltip
        timeAxisHeaderMenu: TimeAxisHeaderMenu
        timeRanges: TimeRanges
        tree: Tree
    }

    type GanttFeaturesConfigType = {
        baselines: string|boolean|Partial<BaselinesConfig>
        cellEdit: string|boolean|Partial<CellEditConfig>
        cellMenu: string|boolean|Partial<CellMenuConfig>
        cellTooltip: string|boolean|Partial<CellTooltipConfig>
        columnAutoWidth: string|boolean|Partial<ColumnAutoWidthConfig>
        columnDragToolbar: string|boolean|Partial<ColumnDragToolbarConfig>
        columnLines: string|boolean|Partial<ColumnLinesConfig>
        columnPicker: string|boolean|Partial<ColumnPickerConfig>
        columnReorder: string|boolean|Partial<ColumnReorderConfig>
        columnResize: string|boolean|Partial<ColumnResizeConfig>
        contextMenu: string|boolean|Partial<ContextMenuConfig>
        criticalPaths: string|boolean|Partial<CriticalPathsConfig>
        dependencies: string|boolean|Partial<DependenciesConfig>
        dependencyEdit: string|boolean|Partial<DependencyEditConfig>
        eventFilter: string|boolean|Partial<EventFilterConfig>
        excelExporter: string|boolean|Partial<GridExcelExporterConfig>
        filter: string|boolean|Partial<FilterConfig>
        filterBar: string|boolean|Partial<FilterBarConfig>
        group: string|boolean|Partial<GroupConfig>
        groupSummary: string|boolean|Partial<GridGroupSummaryConfig>
        headerContextMenu: string|boolean|Partial<HeaderContextMenuConfig>
        headerMenu: string|boolean|Partial<HeaderMenuConfig>
        headerZoom: string|boolean|Partial<HeaderZoomConfig>
        indicators: string|boolean|Partial<IndicatorsConfig>
        labels: string|boolean|Partial<LabelsConfig>
        mspExport: string|boolean|Partial<MspExportConfig>
        nonWorkingTime: string|boolean|Partial<NonWorkingTimeConfig>
        pan: string|boolean|Partial<PanConfig>
        pdfExport: string|boolean|Partial<PdfExportConfig>
        percentBar: string|boolean|Partial<PercentBarConfig>
        progressLine: string|boolean|Partial<ProgressLineConfig>
        projectLines: string|boolean|Partial<ProjectLinesConfig>
        quickFind: string|boolean|Partial<QuickFindConfig>
        regionResize: string|boolean|Partial<RegionResizeConfig>
        rollups: string|boolean|Partial<RollupsConfig>
        rowCopyPaste: string|boolean|Partial<RowCopyPasteConfig>
        rowReorder: string|boolean|Partial<RowReorderConfig>
        scheduleMenu: string|boolean|Partial<ScheduleMenuConfig>
        scheduleTooltip: string|boolean|Partial<ScheduleTooltipConfig>
        search: string|boolean|Partial<SearchConfig>
        sort: string|boolean|Partial<SortConfig>
        stickyCells: string|boolean|Partial<StickyCellsConfig>
        stripe: string|boolean|Partial<StripeConfig>
        summary: string|boolean|Partial<SummaryConfig>
        taskContextMenu: string|boolean|Partial<TaskContextMenuConfig>
        taskCopyPaste: string|boolean|Partial<TaskCopyPasteConfig>
        taskDrag: string|boolean|Partial<TaskDragConfig>
        taskDragCreate: string|boolean|Partial<TaskDragCreateConfig>
        taskEdit: string|boolean|Partial<TaskEditConfig>
        taskMenu: string|boolean|Partial<TaskMenuConfig>
        taskResize: string|boolean|Partial<TaskResizeConfig>
        taskTooltip: string|boolean|Partial<TaskTooltipConfig>
        timeAxisHeaderMenu: string|boolean|Partial<TimeAxisHeaderMenuConfig>
        timeRanges: string|boolean|Partial<TimeRangesConfig>
        tree: string|boolean|Partial<TreeConfig>
    }

    type GanttConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        allowCreate: boolean
        allowDropOnEventBar: boolean
        allowOver: boolean
        anchor: boolean
        anchorToTarget: boolean
        animateRemovingRows: boolean
        appendTo: HTMLElement|string
        autoAdjustTimeAxis: boolean
        autoClose: boolean
        autoHeight: boolean
        autoShow: boolean
        barMargin: number
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        bufferCoef: number
        bufferThreshold: number
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        columnLines: boolean
        columns: object[]|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        contextMenuTriggerEvent: string
        creationTooltip: object
        data: object[]
        dataset: object
        defaultBindProperty: string
        defaultRegion: string
        defaultResourceImageName: string
        defaults: object
        dependencyIdField: string
        destroyStore: boolean
        disableGridRowModelWarning: boolean
        disabled: boolean
        dismissDelay: number
        displayDateFormat: string
        dock: string
        draggable: boolean|object
        durationDisplayPrecision: number|boolean
        emptyText: string
        enableDeleteKey: boolean
        enableEventAnimations: boolean
        enableRecurringEvents: boolean
        enableSticky: boolean
        enableTextSelection: boolean
        enableUndoRedoKeys: boolean
        endDate: Date|string
        eventColor: string
        eventStyle: string
        features: Partial<GanttFeaturesConfigType>
        fillLastColumn: boolean
        fixedRowHeight: boolean
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        forSelector: string
        forceFit: boolean
        fullRowRefresh: boolean
        getDateConstraints: Function
        getHtml: Function
        getRowHeight: Function
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideDelay: number
        hideHeaders: boolean
        hideOnDelegateChange: boolean
        hideWhenEmpty: boolean
        hoverDelay: number
        html: string
        htmlCls: string|object
        id: string
        infiniteScroll: boolean
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        loadMask: string|object|null
        loadMaskDefaults: object|Mask|Partial<MaskConfig>
        loadMaskError: object|Mask|Partial<MaskConfig>
        loadingMsg: string
        localeClass: Base
        localizableProperties: string[]
        longPressTime: number
        managedEventSizing: boolean
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maxZoomLevel: number
        maximizable: boolean
        maximized: boolean
        minHeight: string|number
        minWidth: string|number
        minZoomLevel: number
        modal: boolean
        monitorResize: boolean
        mouseOffsetX: number
        mouseOffsetY: number
        namedItems: object
        owner: Widget
        partner: TimelineBase
        plugins: Function[]
        positioned: boolean
        preserveFocusOnDatasetChange: boolean
        preserveScrollOnDatasetChange: boolean
        presets: object[]
        preventTooltipOnTouch: boolean
        project: ProjectModel|object|Partial<ProjectModelConfig>
        readOnly: boolean
        ref: string
        resizeToFitIncludesHeader: boolean
        resourceImageFolderPath: string
        responsiveLevels: object
        ripple: boolean|object
        rootElement: ShadowRoot
        rowHeight: number
        scrollAction: string
        scrollManager: object|ScrollManager|Partial<ScrollManagerConfig>
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        scrollerClass: Scroller
        selectionMode: object
        showAnimation: boolean|object
        showCreationTooltip: boolean
        showDirty: boolean
        showOnClick: boolean
        showOnHover: boolean
        showRemoveRowInContextMenu: boolean
        snap: boolean
        snapRelativeToEventStartDate: boolean
        startDate: Date|string
        stickyHeaders: boolean
        store: Store|object|Partial<StoreConfig>
        strips: object
        style: string
        subGridConfigs: object
        suppressFit: boolean
        syncMask: string|object|null
        tab: boolean|object
        tag: string
        taskRenderer: Function
        taskStore: TaskStore
        tasks: TaskModel[]|object[]|Partial<TaskModelConfig>[]
        tbar: object[]|object
        terminalCls: string
        terminalSides: string[]
        textAlign: string
        textContent: boolean
        tickSize: number
        timeAxis: object|TimeAxis|Partial<TimeAxisConfig>
        title: string
        toggleParentTasksOnClick: boolean
        tools: object
        tooltip: string|object
        transitionDuration: number
        trapFocus: boolean
        viewPreset: string|object
        visibleDate: Date|object
        visibleZoomFactor: number
        weekStartDay: number
        weight: number
        width: string|number
        workingTime: object
        x: number
        y: number
        zoomKeepsOriginalTimespan: boolean
        zoomOnMouseWheel: boolean
        zoomOnTimeAxisDoubleClick: boolean
    }

    export class Gantt extends GanttBase {
        features: GanttFeaturesType
        constructor(config?: Partial<GanttConfig>);
    }

    type GanttBaseFeaturesType = {
        baselines: Baselines
        cellEdit: CellEdit
        cellMenu: CellMenu
        cellTooltip: CellTooltip
        columnAutoWidth: ColumnAutoWidth
        columnDragToolbar: ColumnDragToolbar
        columnLines: ColumnLines
        columnPicker: ColumnPicker
        columnReorder: ColumnReorder
        columnResize: ColumnResize
        contextMenu: ContextMenu
        criticalPaths: CriticalPaths
        dependencies: Dependencies
        dependencyEdit: DependencyEdit
        eventFilter: EventFilter
        excelExporter: GridExcelExporter
        filter: Filter
        filterBar: FilterBar
        group: Group
        groupSummary: GridGroupSummary
        headerContextMenu: HeaderContextMenu
        headerMenu: HeaderMenu
        headerZoom: HeaderZoom
        indicators: Indicators
        labels: Labels
        mspExport: MspExport
        nonWorkingTime: NonWorkingTime
        pan: Pan
        pdfExport: PdfExport
        percentBar: PercentBar
        progressLine: ProgressLine
        projectLines: ProjectLines
        quickFind: QuickFind
        regionResize: RegionResize
        rollups: Rollups
        rowCopyPaste: RowCopyPaste
        rowReorder: RowReorder
        scheduleMenu: ScheduleMenu
        scheduleTooltip: ScheduleTooltip
        search: Search
        sort: Sort
        stickyCells: StickyCells
        stripe: Stripe
        summary: Summary
        taskContextMenu: TaskContextMenu
        taskCopyPaste: TaskCopyPaste
        taskDrag: TaskDrag
        taskDragCreate: TaskDragCreate
        taskEdit: TaskEdit
        taskMenu: TaskMenu
        taskResize: TaskResize
        taskTooltip: TaskTooltip
        timeAxisHeaderMenu: TimeAxisHeaderMenu
        timeRanges: TimeRanges
        tree: Tree
    }

    type GanttBaseFeaturesConfigType = {
        baselines: string|boolean|Partial<BaselinesConfig>
        cellEdit: string|boolean|Partial<CellEditConfig>
        cellMenu: string|boolean|Partial<CellMenuConfig>
        cellTooltip: string|boolean|Partial<CellTooltipConfig>
        columnAutoWidth: string|boolean|Partial<ColumnAutoWidthConfig>
        columnDragToolbar: string|boolean|Partial<ColumnDragToolbarConfig>
        columnLines: string|boolean|Partial<ColumnLinesConfig>
        columnPicker: string|boolean|Partial<ColumnPickerConfig>
        columnReorder: string|boolean|Partial<ColumnReorderConfig>
        columnResize: string|boolean|Partial<ColumnResizeConfig>
        contextMenu: string|boolean|Partial<ContextMenuConfig>
        criticalPaths: string|boolean|Partial<CriticalPathsConfig>
        dependencies: string|boolean|Partial<DependenciesConfig>
        dependencyEdit: string|boolean|Partial<DependencyEditConfig>
        eventFilter: string|boolean|Partial<EventFilterConfig>
        excelExporter: string|boolean|Partial<GridExcelExporterConfig>
        filter: string|boolean|Partial<FilterConfig>
        filterBar: string|boolean|Partial<FilterBarConfig>
        group: string|boolean|Partial<GroupConfig>
        groupSummary: string|boolean|Partial<GridGroupSummaryConfig>
        headerContextMenu: string|boolean|Partial<HeaderContextMenuConfig>
        headerMenu: string|boolean|Partial<HeaderMenuConfig>
        headerZoom: string|boolean|Partial<HeaderZoomConfig>
        indicators: string|boolean|Partial<IndicatorsConfig>
        labels: string|boolean|Partial<LabelsConfig>
        mspExport: string|boolean|Partial<MspExportConfig>
        nonWorkingTime: string|boolean|Partial<NonWorkingTimeConfig>
        pan: string|boolean|Partial<PanConfig>
        pdfExport: string|boolean|Partial<PdfExportConfig>
        percentBar: string|boolean|Partial<PercentBarConfig>
        progressLine: string|boolean|Partial<ProgressLineConfig>
        projectLines: string|boolean|Partial<ProjectLinesConfig>
        quickFind: string|boolean|Partial<QuickFindConfig>
        regionResize: string|boolean|Partial<RegionResizeConfig>
        rollups: string|boolean|Partial<RollupsConfig>
        rowCopyPaste: string|boolean|Partial<RowCopyPasteConfig>
        rowReorder: string|boolean|Partial<RowReorderConfig>
        scheduleMenu: string|boolean|Partial<ScheduleMenuConfig>
        scheduleTooltip: string|boolean|Partial<ScheduleTooltipConfig>
        search: string|boolean|Partial<SearchConfig>
        sort: string|boolean|Partial<SortConfig>
        stickyCells: string|boolean|Partial<StickyCellsConfig>
        stripe: string|boolean|Partial<StripeConfig>
        summary: string|boolean|Partial<SummaryConfig>
        taskContextMenu: string|boolean|Partial<TaskContextMenuConfig>
        taskCopyPaste: string|boolean|Partial<TaskCopyPasteConfig>
        taskDrag: string|boolean|Partial<TaskDragConfig>
        taskDragCreate: string|boolean|Partial<TaskDragCreateConfig>
        taskEdit: string|boolean|Partial<TaskEditConfig>
        taskMenu: string|boolean|Partial<TaskMenuConfig>
        taskResize: string|boolean|Partial<TaskResizeConfig>
        taskTooltip: string|boolean|Partial<TaskTooltipConfig>
        timeAxisHeaderMenu: string|boolean|Partial<TimeAxisHeaderMenuConfig>
        timeRanges: string|boolean|Partial<TimeRangesConfig>
        tree: string|boolean|Partial<TreeConfig>
    }

    type GanttBaseConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        allowCreate: boolean
        allowDropOnEventBar: boolean
        allowOver: boolean
        anchor: boolean
        anchorToTarget: boolean
        animateRemovingRows: boolean
        appendTo: HTMLElement|string
        autoAdjustTimeAxis: boolean
        autoClose: boolean
        autoHeight: boolean
        autoShow: boolean
        barMargin: number
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        bufferCoef: number
        bufferThreshold: number
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        columnLines: boolean
        columns: object[]|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        contextMenuTriggerEvent: string
        creationTooltip: object
        data: object[]
        dataset: object
        defaultBindProperty: string
        defaultRegion: string
        defaultResourceImageName: string
        defaults: object
        dependencyIdField: string
        destroyStore: boolean
        disableGridRowModelWarning: boolean
        disabled: boolean
        dismissDelay: number
        displayDateFormat: string
        dock: string
        draggable: boolean|object
        durationDisplayPrecision: number|boolean
        emptyText: string
        enableDeleteKey: boolean
        enableEventAnimations: boolean
        enableRecurringEvents: boolean
        enableSticky: boolean
        enableTextSelection: boolean
        enableUndoRedoKeys: boolean
        endDate: Date|string
        eventColor: string
        eventStyle: string
        features: Partial<GanttBaseFeaturesConfigType>
        fillLastColumn: boolean
        fixedRowHeight: boolean
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        forSelector: string
        forceFit: boolean
        fullRowRefresh: boolean
        getDateConstraints: Function
        getHtml: Function
        getRowHeight: Function
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideDelay: number
        hideHeaders: boolean
        hideOnDelegateChange: boolean
        hideWhenEmpty: boolean
        hoverDelay: number
        html: string
        htmlCls: string|object
        id: string
        infiniteScroll: boolean
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        loadMask: string|object|null
        loadMaskDefaults: object|Mask|Partial<MaskConfig>
        loadMaskError: object|Mask|Partial<MaskConfig>
        loadingMsg: string
        localeClass: Base
        localizableProperties: string[]
        longPressTime: number
        managedEventSizing: boolean
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maxZoomLevel: number
        maximizable: boolean
        maximized: boolean
        minHeight: string|number
        minWidth: string|number
        minZoomLevel: number
        modal: boolean
        monitorResize: boolean
        mouseOffsetX: number
        mouseOffsetY: number
        namedItems: object
        owner: Widget
        partner: TimelineBase
        plugins: Function[]
        positioned: boolean
        preserveFocusOnDatasetChange: boolean
        preserveScrollOnDatasetChange: boolean
        presets: object[]
        preventTooltipOnTouch: boolean
        project: ProjectModel|object|Partial<ProjectModelConfig>
        readOnly: boolean
        ref: string
        resizeToFitIncludesHeader: boolean
        resourceImageFolderPath: string
        responsiveLevels: object
        ripple: boolean|object
        rootElement: ShadowRoot
        rowHeight: number
        scrollAction: string
        scrollManager: object|ScrollManager|Partial<ScrollManagerConfig>
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        scrollerClass: Scroller
        selectionMode: object
        showAnimation: boolean|object
        showCreationTooltip: boolean
        showDirty: boolean
        showOnClick: boolean
        showOnHover: boolean
        showRemoveRowInContextMenu: boolean
        snap: boolean
        snapRelativeToEventStartDate: boolean
        startDate: Date|string
        stickyHeaders: boolean
        store: Store|object|Partial<StoreConfig>
        strips: object
        style: string
        subGridConfigs: object
        suppressFit: boolean
        syncMask: string|object|null
        tab: boolean|object
        tag: string
        taskRenderer: Function
        taskStore: TaskStore
        tasks: TaskModel[]|object[]|Partial<TaskModelConfig>[]
        tbar: object[]|object
        terminalCls: string
        terminalSides: string[]
        textAlign: string
        textContent: boolean
        tickSize: number
        timeAxis: object|TimeAxis|Partial<TimeAxisConfig>
        title: string
        toggleParentTasksOnClick: boolean
        tools: object
        tooltip: string|object
        transitionDuration: number
        trapFocus: boolean
        viewPreset: string|object
        visibleDate: Date|object
        visibleZoomFactor: number
        weekStartDay: number
        weight: number
        width: string|number
        workingTime: object
        x: number
        y: number
        zoomKeepsOriginalTimespan: boolean
        zoomOnMouseWheel: boolean
        zoomOnTimeAxisDoubleClick: boolean
        onAfterDependencyCreateDrop: Function
        onAfterDependencySave: Function
        onAfterDragCreate: Function
        onAfterEventSave: Function
        onAfterTaskDrop: Function
        onAfterTaskSave: Function
        onBeforeAssignmentDelete: Function
        onBeforeCellEditStart: Function
        onBeforeDependencyAdd: Function
        onBeforeDependencyCreateDrag: Function
        onBeforeDependencyCreateFinalize: Function
        onBeforeDependencyDelete: Function
        onBeforeDependencyEdit: Function
        onBeforeDependencyEditShow: Function
        onBeforeDependencySave: Function
        onBeforeDestroy: Function
        onBeforeDragCreate: Function
        onBeforeDragCreateFinalize: Function
        onBeforeEventDelete: Function
        onBeforeEventResize: Function
        onBeforeEventResizeFinalize: Function
        onBeforeEventSave: Function
        onBeforeExport: Function
        onBeforeFinishCellEdit: Function
        onBeforeTaskDelete: Function
        onBeforeTaskDrag: Function
        onBeforeTaskDropFinalize: Function
        onBeforeTaskEdit: Function
        onBeforeTaskEditShow: Function
        onBeforeTaskResize: Function
        onBeforeTaskResizeFinalize: Function
        onBeforeTaskSave: Function
        onCancelCellEdit: Function
        onCatchAll: Function
        onContextMenuItem: Function
        onContextMenuToggleItem: Function
        onDependencyClick: Function
        onDependencyCreateDragStart: Function
        onDependencyCreateDrop: Function
        onDependencyDblClick: Function
        onDependencyMouseOut: Function
        onDependencyMouseOver: Function
        onDependencyValidationComplete: Function
        onDependencyValidationStart: Function
        onDestroy: Function
        onDragCreateEnd: Function
        onDragCreateStart: Function
        onEventMenuBeforeShow: Function
        onEventMenuItem: Function
        onEventMenuShow: Function
        onEventPartialResize: Function
        onEventResizeEnd: Function
        onEventResizeStart: Function
        onExport: Function
        onFinishCellEdit: Function
        onHeaderMenuBeforeShow: Function
        onHeaderMenuItem: Function
        onHeaderMenuShow: Function
        onHeaderMenuToggleItem: Function
        onNavigate: Function
        onReleaseTask: Function
        onRenderTask: Function
        onScheduleMenuBeforeShow: Function
        onScheduleMenuItem: Function
        onScheduleMenuShow: Function
        onStartCellEdit: Function
        onTaskClick: Function
        onTaskContextMenu: Function
        onTaskContextMenuBeforeShow: Function
        onTaskContextMenuItem: Function
        onTaskContextMenuShow: Function
        onTaskDblClick: Function
        onTaskDrag: Function
        onTaskDragStart: Function
        onTaskDrop: Function
        onTaskKeyDown: Function
        onTaskKeyUp: Function
        onTaskMenuBeforeShow: Function
        onTaskMenuItem: Function
        onTaskMenuShow: Function
        onTaskMouseDown: Function
        onTaskMouseOut: Function
        onTaskMouseOver: Function
        onTaskMouseUp: Function
        onTaskPartialResize: Function
        onTaskResizeEnd: Function
        onTaskResizeStart: Function
        onTimeAxisHeaderContextMenuBeforeShow: Function
        onTimeAxisHeaderContextMenuItem: Function
        onTimeAxisHeaderContextMenuShow: Function
    }

    export class GanttBase extends TimelineBase implements GanttDom, GanttRegions, GanttScroll, GanttState, GanttStores, CrudManagerView, EventNavigation, TaskNavigation {
        allowDropOnEventBar: boolean
        localeManager: typeof LocaleManager
        project: ProjectModel
        readOnly: boolean
        state: object
        taskStore: TaskStore
        tasks: TaskModel[]|object[]|Partial<TaskModelConfig>[]
        toggleParentTasksOnClick: boolean
        features: GanttBaseFeaturesType
        onAfterDependencyCreateDrop: Function
        onAfterDependencySave: Function
        onAfterDragCreate: Function
        onAfterEventSave: Function
        onAfterTaskDrop: Function
        onAfterTaskSave: Function
        onBeforeAssignmentDelete: Function
        onBeforeCellEditStart: Function
        onBeforeDependencyAdd: Function
        onBeforeDependencyCreateDrag: Function
        onBeforeDependencyCreateFinalize: Function
        onBeforeDependencyDelete: Function
        onBeforeDependencyEdit: Function
        onBeforeDependencyEditShow: Function
        onBeforeDependencySave: Function
        onBeforeDestroy: Function
        onBeforeDragCreate: Function
        onBeforeDragCreateFinalize: Function
        onBeforeEventDelete: Function
        onBeforeEventResize: Function
        onBeforeEventResizeFinalize: Function
        onBeforeEventSave: Function
        onBeforeExport: Function
        onBeforeFinishCellEdit: Function
        onBeforeTaskDelete: Function
        onBeforeTaskDrag: Function
        onBeforeTaskDropFinalize: Function
        onBeforeTaskEdit: Function
        onBeforeTaskEditShow: Function
        onBeforeTaskResize: Function
        onBeforeTaskResizeFinalize: Function
        onBeforeTaskSave: Function
        onCancelCellEdit: Function
        onCatchAll: Function
        onContextMenuItem: Function
        onContextMenuToggleItem: Function
        onDependencyClick: Function
        onDependencyCreateDragStart: Function
        onDependencyCreateDrop: Function
        onDependencyDblClick: Function
        onDependencyMouseOut: Function
        onDependencyMouseOver: Function
        onDependencyValidationComplete: Function
        onDependencyValidationStart: Function
        onDestroy: Function
        onDragCreateEnd: Function
        onDragCreateStart: Function
        onEventMenuBeforeShow: Function
        onEventMenuItem: Function
        onEventMenuShow: Function
        onEventPartialResize: Function
        onEventResizeEnd: Function
        onEventResizeStart: Function
        onExport: Function
        onFinishCellEdit: Function
        onHeaderMenuBeforeShow: Function
        onHeaderMenuItem: Function
        onHeaderMenuShow: Function
        onHeaderMenuToggleItem: Function
        onNavigate: Function
        onReleaseTask: Function
        onRenderTask: Function
        onScheduleMenuBeforeShow: Function
        onScheduleMenuItem: Function
        onScheduleMenuShow: Function
        onStartCellEdit: Function
        onTaskClick: Function
        onTaskContextMenu: Function
        onTaskContextMenuBeforeShow: Function
        onTaskContextMenuItem: Function
        onTaskContextMenuShow: Function
        onTaskDblClick: Function
        onTaskDrag: Function
        onTaskDragStart: Function
        onTaskDrop: Function
        onTaskKeyDown: Function
        onTaskKeyUp: Function
        onTaskMenuBeforeShow: Function
        onTaskMenuItem: Function
        onTaskMenuShow: Function
        onTaskMouseDown: Function
        onTaskMouseOut: Function
        onTaskMouseOver: Function
        onTaskMouseUp: Function
        onTaskPartialResize: Function
        onTaskResizeEnd: Function
        onTaskResizeStart: Function
        onTimeAxisHeaderContextMenuBeforeShow: Function
        onTimeAxisHeaderContextMenuItem: Function
        onTimeAxisHeaderContextMenuShow: Function
        constructor(config?: Partial<GanttBaseConfig>);
        static optionalL(text: string, templateData?: object): string;
        L(text: string, templateData?: object): string;
        abort(): void;
        addListener(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        addMilestoneBelow(taskRecord: TaskModel): TaskModel;
        addPredecessor(taskRecord: TaskModel): TaskModel;
        addSubtask(taskRecord: TaskModel): TaskModel;
        addSuccessor(taskRecord: TaskModel): TaskModel;
        addTaskAbove(taskRecord: TaskModel): TaskModel;
        addTaskBelow(taskRecord: TaskModel): TaskModel;
        copyRows(isCut?: boolean): void;
        editTask(taskRecord: TaskModel, element?: HTMLElement): Promise<any>;
        getElementFromTaskRecord(taskRecord: TaskModel, inner?: boolean): HTMLElement;
        getScheduleRegion(taskRecord: TaskModel): object;
        getTaskBox(taskRecord: TaskModel, includeOutside?: boolean, inner?: boolean): Rectangle;
        hasListener(eventName: string): boolean;
        hideTerminals(eventElement: HTMLElement): void;
        indent(tasks: TaskModel[]|TaskModel): Promise<any>;
        on(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        outdent(tasks: TaskModel[]|TaskModel): Promise<any>;
        pasteRows(record?: object): void;
        relayAll(through: Events, prefix: string, transformCase?: boolean): void;
        removeAllListeners(): void;
        removeListener(config: object, thisObj: object): void;
        resolveDependencyRecord(element: HTMLElement): DependencyModel;
        resolveTaskRecord(element: HTMLElement): TaskModel;
        resumeEvents(): void;
        scrollTaskIntoView(taskRecord: TaskModel, options?: object): Promise<any>;
        showContextMenu(event: Event, alignSpec?: object|HTMLElement): void;
        showTerminals(timeSpanRecord: TimeSpan, element: HTMLElement): void;
        startEditing(cellContext: object): boolean;
        suspendEvents(queue?: boolean): void;
        trigger(eventName: string, param?: object): boolean|Promise<any>;
        un(config: object, thisObj?: object): void;
        updateLocalization(): void;
    }

    export class GanttDom {
        getElementFromTaskRecord(taskRecord: TaskModel, inner?: boolean): HTMLElement;
        resolveTaskRecord(element: HTMLElement): TaskModel;
    }

    export class GanttRegions {
        getScheduleRegion(taskRecord: TaskModel): object;
        getTaskBox(taskRecord: TaskModel, includeOutside?: boolean, inner?: boolean): Rectangle;
    }

    export class GanttScroll {
        scrollTaskIntoView(taskRecord: TaskModel, options?: object): Promise<any>;
    }

    export class GanttState {
        state: object
    }

    type GanttStoresConfig = {
        taskStore: TaskStore
        tasks: TaskModel[]|object[]|Partial<TaskModelConfig>[]
    }

    export class GanttStores {
        taskStore: TaskStore
        tasks: TaskModel[]|object[]|Partial<TaskModelConfig>[]
        constructor(config?: Partial<GanttStoresConfig>);
    }

    export class TaskNavigation {
    }

    type AssignmentFieldConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoComplete: string
        autoExpand: boolean
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        caseSensitive: boolean
        centered: boolean
        chipView: object
        clearTextOnPickerHide: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        displayField: string
        displayValueRenderer: Function
        dock: string
        draggable: boolean|object
        editable: boolean
        emptyText: string
        encodeFilterParams: Function
        filterOnEnter: boolean
        filterOperator: string
        filterParamName: string
        filterSelected: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hidePickerOnSelect: boolean
        hideTrigger: boolean
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        items: object[]|string[]|object
        keyStrokeChangeDelay: number
        keyStrokeFilterDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listCls: string
        listItemTpl: Function
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        minChars: number
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        multiSelect: boolean
        name: string
        overlayAnchor: boolean
        owner: Widget
        picker: object|AssignmentGrid|Partial<AssignmentGridConfig>
        pickerAlignElement: string
        pickerWidth: number
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        primaryFilter: object
        projectEvent: TaskModel
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        store: Store|object|Partial<StoreConfig>
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggerAction: string
        triggers: object
        validateFilter: boolean
        value: string|number[]|string[]
        valueField: string
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class AssignmentField extends Combo {
        constructor(config?: Partial<AssignmentFieldConfig>);
    }

    type AssignmentGridFeaturesType = {
        cellEdit: GridCellEdit
        cellMenu: CellMenu
        cellTooltip: CellTooltip
        columnAutoWidth: ColumnAutoWidth
        columnDragToolbar: ColumnDragToolbar
        columnPicker: ColumnPicker
        columnReorder: ColumnReorder
        columnResize: ColumnResize
        contextMenu: ContextMenu
        excelExporter: GridExcelExporter
        filter: Filter
        filterBar: FilterBar
        group: Group
        groupSummary: GridGroupSummary
        headerMenu: HeaderMenu
        pdfExport: GridPdfExport
        quickFind: QuickFind
        regionResize: RegionResize
        rowCopyPaste: RowCopyPaste
        rowReorder: RowReorder
        search: Search
        sort: Sort
        stickyCells: StickyCells
        stripe: Stripe
        summary: GridSummary
        tree: Tree
    }

    type AssignmentGridFeaturesConfigType = {
        cellEdit: string|boolean|Partial<GridCellEditConfig>
        cellMenu: string|boolean|Partial<CellMenuConfig>
        cellTooltip: string|boolean|Partial<CellTooltipConfig>
        columnAutoWidth: string|boolean|Partial<ColumnAutoWidthConfig>
        columnDragToolbar: string|boolean|Partial<ColumnDragToolbarConfig>
        columnPicker: string|boolean|Partial<ColumnPickerConfig>
        columnReorder: string|boolean|Partial<ColumnReorderConfig>
        columnResize: string|boolean|Partial<ColumnResizeConfig>
        contextMenu: string|boolean|Partial<ContextMenuConfig>
        excelExporter: string|boolean|Partial<GridExcelExporterConfig>
        filter: string|boolean|Partial<FilterConfig>
        filterBar: string|boolean|Partial<FilterBarConfig>
        group: string|boolean|Partial<GroupConfig>
        groupSummary: string|boolean|Partial<GridGroupSummaryConfig>
        headerMenu: string|boolean|Partial<HeaderMenuConfig>
        pdfExport: string|boolean|Partial<GridPdfExportConfig>
        quickFind: string|boolean|Partial<QuickFindConfig>
        regionResize: string|boolean|Partial<RegionResizeConfig>
        rowCopyPaste: string|boolean|Partial<RowCopyPasteConfig>
        rowReorder: string|boolean|Partial<RowReorderConfig>
        search: string|boolean|Partial<SearchConfig>
        sort: string|boolean|Partial<SortConfig>
        stickyCells: string|boolean|Partial<StickyCellsConfig>
        stripe: string|boolean|Partial<StripeConfig>
        summary: string|boolean|Partial<GridSummaryConfig>
        tree: string|boolean|Partial<TreeConfig>
    }

    type AssignmentGridConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        animateRemovingRows: boolean
        appendTo: HTMLElement|string
        autoHeight: boolean
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        centered: boolean
        cls: string|object
        columnLines: boolean
        columns: object[]|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        contextMenuTriggerEvent: string
        data: object[]
        dataset: object
        defaultBindProperty: string
        defaultRegion: string
        defaults: object
        destroyStore: boolean
        disableGridRowModelWarning: boolean
        disabled: boolean
        dock: string
        draggable: boolean|object
        emptyText: string
        enableSticky: boolean
        enableTextSelection: boolean
        enableUndoRedoKeys: boolean
        features: Partial<AssignmentGridFeaturesConfigType>
        fillLastColumn: boolean
        fixedRowHeight: boolean
        flex: number|string
        floating: boolean
        footer: object|string
        fullRowRefresh: boolean
        getRowHeight: Function
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideHeaders: boolean
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        loadMask: string|object|null
        loadMaskDefaults: object|Mask|Partial<MaskConfig>
        loadMaskError: object|Mask|Partial<MaskConfig>
        localeClass: Base
        localizableProperties: string[]
        longPressTime: number
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        plugins: Function[]
        positioned: boolean
        preserveFocusOnDatasetChange: boolean
        preserveScrollOnDatasetChange: boolean
        preventTooltipOnTouch: boolean
        projectEvent: TaskModel
        readOnly: boolean
        ref: string
        resizeToFitIncludesHeader: boolean
        resourceColumn: object
        responsiveLevels: object
        ripple: boolean|object
        rootElement: ShadowRoot
        rowHeight: number
        scrollAction: string
        scrollManager: object|ScrollManager|Partial<ScrollManagerConfig>
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        scrollerClass: Scroller
        selectionMode: object
        showAnimation: boolean|object
        showDirty: boolean
        showRemoveRowInContextMenu: boolean
        store: Store|object|Partial<StoreConfig>
        strips: object
        style: string
        subGridConfigs: object
        syncMask: string|object|null
        tab: boolean|object
        tag: string
        tbar: object[]|object
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        transitionDuration: number
        trapFocus: boolean
        unitsColumn: object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class AssignmentGrid extends Grid {
        features: AssignmentGridFeaturesType
        constructor(config?: Partial<AssignmentGridConfig>);
    }

    type CalendarPickerConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoComplete: string
        autoExpand: boolean
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        caseSensitive: boolean
        centered: boolean
        chipView: object
        clearTextOnPickerHide: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        displayField: string
        displayValueRenderer: Function
        dock: string
        draggable: boolean|object
        editable: boolean
        emptyText: string
        encodeFilterParams: Function
        filterOnEnter: boolean
        filterOperator: string
        filterParamName: string
        filterSelected: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hidePickerOnSelect: boolean
        hideTrigger: boolean
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        items: object[]|string[]|object
        keyStrokeChangeDelay: number
        keyStrokeFilterDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listCls: string
        listItemTpl: Function
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        minChars: number
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        multiSelect: boolean
        name: string
        overlayAnchor: boolean
        owner: Widget
        picker: object
        pickerAlignElement: string
        pickerWidth: number
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        primaryFilter: object
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        store: Store
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggerAction: string
        triggers: object
        validateFilter: boolean
        value: string|number[]|string[]
        valueField: string
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class CalendarPicker extends Combo {
        constructor(config?: Partial<CalendarPickerConfig>);
        refreshCalendars(calendars: CalendarModel[]): void;
    }

    type DependencyFieldConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoComplete: string
        autoExpand: boolean
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        caseSensitive: boolean
        centered: boolean
        chipView: object
        clearTextOnPickerHide: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        delimiter: string
        dependencyIdField: string
        dependencyStore: DependencyStore
        disabled: boolean
        displayField: string
        displayValueRenderer: Function
        dock: string
        draggable: boolean|object
        editable: boolean
        emptyText: string
        encodeFilterParams: Function
        filterOnEnter: boolean
        filterOperator: string
        filterParamName: string
        filterSelected: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hidePickerOnSelect: boolean
        hideTrigger: boolean
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        items: object[]|string[]|object
        keyStrokeChangeDelay: number
        keyStrokeFilterDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listCls: string
        listItemTpl: Function
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        minChars: number
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        multiSelect: boolean
        name: string
        otherSide: string
        ourSide: string
        overlayAnchor: boolean
        owner: Widget
        picker: object
        pickerAlignElement: string
        pickerWidth: number
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        primaryFilter: object
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        sorters: object[]|string[]
        store: Store
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggerAction: string
        triggers: object
        validateFilter: boolean
        value: string|number[]|string[]
        valueField: string
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class DependencyField extends Combo {
        constructor(config?: Partial<DependencyFieldConfig>);
    }

    type TaskEditorConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoShow: boolean
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        calculateMask: string|null
        calculateMaskDelay: number|null
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        dependencyIdField: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        durationDisplayPrecision: number
        extraItems: object
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maximizable: boolean
        maximized: boolean
        minHeight: string|number
        minWidth: string|number
        modal: boolean
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showOnClick: boolean
        strips: object
        style: string
        tab: boolean|object
        tabsConfig: object
        tag: string
        tbar: object[]|object
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        trapFocus: boolean
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class TaskEditor extends GanttTaskEditor {
        constructor(config?: Partial<TaskEditorConfig>);
    }

    type ActionColumnConfig = {
        actions: object[]
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        disableIfGridReadOnly: boolean
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class ActionColumn extends Column {
        constructor(config?: Partial<ActionColumnConfig>);
    }

    type AggregateColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        function: Function|string
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class AggregateColumn extends Column {
        constructor(config?: Partial<AggregateColumnConfig>);
    }

    type CheckColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        checkCls: string
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showCheckAll: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        widgets: object[]
        width: number|string
        onBeforeToggle: Function
        onToggle: Function
        onToggleAll: Function
    }

    export class CheckColumn extends WidgetColumn {
        onBeforeToggle: Function
        onToggle: Function
        onToggleAll: Function
        constructor(config?: Partial<CheckColumnConfig>);
    }

    type ColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
        onBeforeDestroy: Function
        onCatchAll: Function
        onDestroy: Function
    }

    export class Column extends Model implements Events, Localizable {
        contentElement: HTMLElement
        defaults: object
        element: HTMLElement
        flex: string
        hidden: boolean
        icon: string
        localeManager: typeof LocaleManager
        subGrid: SubGrid
        text: string
        textElement: HTMLElement
        textWrapper: HTMLElement
        width: number|string
        onBeforeDestroy: Function
        onCatchAll: Function
        onDestroy: Function
        constructor(config?: Partial<ColumnConfig>);
        static optionalL(text: string, templateData?: object): string;
        L(text: string, templateData?: object): string;
        addListener(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        getRawValue(record: Model): any;
        hasListener(eventName: string): boolean;
        hide(): void;
        on(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        refreshCell(record: Model): void;
        relayAll(through: Events, prefix: string, transformCase?: boolean): void;
        removeAllListeners(): void;
        removeListener(config: object, thisObj: object): void;
        resizeToFitContent(widthMin: number|number[], widthMax: number): void;
        resumeEvents(): void;
        show(): void;
        suspendEvents(queue?: boolean): void;
        toggle(force: boolean): void;
        trigger(eventName: string, param?: object): boolean|Promise<any>;
        un(config: object, thisObj?: object): void;
        updateLocalization(): void;
    }

    type DateColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        format: string
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        step: string|number|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class DateColumn extends Column {
        format: string
        constructor(config?: Partial<DateColumnConfig>);
    }

    type NumberColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        format: string|object|NumberFormat|Partial<NumberFormatConfig>
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        largeStep: number
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        max: number
        min: number
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        step: number
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        unit: string
        width: number|string
    }

    export class NumberColumn extends Column {
        constructor(config?: Partial<NumberColumnConfig>);
    }

    type PercentColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: object|string
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        lowThreshold: number
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        showValue: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class PercentColumn extends Column {
        constructor(config?: Partial<PercentColumnConfig>);
    }

    type RatingColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editable: boolean
        editor: boolean|string|object|Field|Partial<FieldConfig>
        emptyIcon: string
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filledIcon: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        format: string|object|NumberFormat|Partial<NumberFormatConfig>
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        largeStep: number
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        max: number
        min: number
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        step: number
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        unit: string
        width: number|string
    }

    export class RatingColumn extends NumberColumn {
        constructor(config?: Partial<RatingColumnConfig>);
    }

    type RowNumberColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class RowNumberColumn extends Column {
        constructor(config?: Partial<RowNumberColumnConfig>);
        resizeToFitContent(): void;
    }

    type TemplateColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        template: Function
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class TemplateColumn extends Column {
        constructor(config?: Partial<TemplateColumnConfig>);
    }

    type TimeColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        format: string
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class TimeColumn extends Column {
        format: string
        constructor(config?: Partial<TimeColumnConfig>);
    }

    type TreeColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        collapseIconCls: string
        collapsedFolderIconCls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        expandIconCls: string
        expandedFolderIconCls: string
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        indentSize: number
        instantUpdate: boolean
        invalidAction: string
        leafIconCls: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class TreeColumn extends Column {
        constructor(config?: Partial<TreeColumnConfig>);
    }

    type WidgetColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        widgets: object[]
        width: number|string
    }

    export class WidgetColumn extends Column {
        constructor(config?: Partial<WidgetColumnConfig>);
        onAfterWidgetSetValue(widget: Widget, renderData: object): void;
        onBeforeWidgetSetValue(widget: Widget, renderData: object): void;
    }

    type ColumnStoreConfig = {
        allowNoId: boolean
        autoAddField: boolean
        autoCommit: boolean
        autoTree: boolean
        bubbleEvents: object
        chainedFields: string[]
        chainedFilterFn: Function
        data: object[]|Model[]|Partial<ModelConfig>[]
        doRelayToMaster: string[]
        dontRelayToMaster: string
        fields: string[]|object[]|DataField[]|Partial<DataFieldConfig>[]
        filters: object|object[]
        groupers: object[]
        id: string|number
        keepUncommittedChanges: boolean
        listeners: object
        masterStore: Store
        modelClass: typeof Model
        reapplyFilterOnAdd: boolean
        reapplyFilterOnUpdate: boolean
        reapplySortersOnAdd: boolean
        sorters: object[]|string[]
        stm: StateTrackingManager
        storage: Collection|object|Partial<CollectionConfig>
        syncDataOnLoad: boolean|object
        transformFlatData: boolean
        tree: boolean
        useLocaleSort: boolean|string|object
        useRawData: boolean|object
        onColumnHide: Function
        onColumnShow: Function
    }

    export class ColumnStore extends Store {
        bottomColumns: Column[]
        topColumns: Column[]
        visibleColumns: Column[]
        onColumnHide: Function
        onColumnShow: Function
        constructor(config?: Partial<ColumnStoreConfig>);
        static registerColumnType(columnClass: Function, simpleRenderer?: boolean): void;
        get(field: string): Column;
        indexOf(recordOrId: Model|string): number;
    }

    type GridRowModelConfig = {
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        expanded: boolean
        href: string
        iconCls: string
        id: string|number
        parentId: string|number|null
        parentIndex: number
        rowHeight: number
        target: string
    }

    export class GridRowModel extends Model {
        cls: string
        expanded: boolean
        href: string
        iconCls: string
        rowHeight: number
        target: string
        constructor(config?: Partial<GridRowModelConfig>);
    }

    type GridCellEditConfig = {
        addNewAtEnd: boolean|object
        autoEdit: boolean
        autoSelect: boolean
        blurAction: string
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        triggerEvent: string
        onBeforeCellEditStart: Function
        onBeforeFinishCellEdit: Function
        onCancelCellEdit: Function
        onFinishCellEdit: Function
        onStartCellEdit: Function
    }

    export class GridCellEdit extends InstancePlugin {
        activeRecord: Model
        isEditing: boolean
        onBeforeCellEditStart: Function
        onBeforeFinishCellEdit: Function
        onCancelCellEdit: Function
        onFinishCellEdit: Function
        onStartCellEdit: Function
        constructor(config?: Partial<GridCellEditConfig>);
        cancelEditing(silent?: boolean): void;
        confirm(options: object): void;
        finishEditing(): void;
        startEditing(cellContext: object): boolean;
    }

    type CellMenuConfig = {
        bubbleEvents: object
        disabled: boolean
        items: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        menu: object
        menuConfig: object
        processItems: Function
        triggerEvent: string
        type: string
        onCellMenuBeforeShow: Function
        onCellMenuItem: Function
        onCellMenuShow: Function
        onCellMenuToggleItem: Function
    }

    export class CellMenu extends ContextMenuBase {
        onCellMenuBeforeShow: Function
        onCellMenuItem: Function
        onCellMenuShow: Function
        onCellMenuToggleItem: Function
        constructor(config?: Partial<CellMenuConfig>);
    }

    type CellTooltipConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        tooltipRenderer: Function
    }

    export class CellTooltip extends InstancePlugin {
        constructor(config?: Partial<CellTooltipConfig>);
    }

    type ColumnAutoWidthConfig = {
        bubbleEvents: object
        default: number|number[]
        delay: number
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
    }

    export class ColumnAutoWidth extends InstancePlugin implements Delayable {
        constructor(config?: Partial<ColumnAutoWidthConfig>);
    }

    type ColumnDragToolbarConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
    }

    export class ColumnDragToolbar extends InstancePlugin {
        constructor(config?: Partial<ColumnDragToolbarConfig>);
    }

    type ColumnPickerConfig = {
        bubbleEvents: object
        createColumnsFromModel: boolean
        disabled: boolean
        groupByRegion: boolean
        groupByTag: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
    }

    export class ColumnPicker extends InstancePlugin {
        constructor(config?: Partial<ColumnPickerConfig>);
    }

    type ColumnReorderConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
    }

    export class ColumnReorder extends InstancePlugin {
        constructor(config?: Partial<ColumnReorderConfig>);
    }

    type ColumnResizeConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        liveResize: string|boolean
        localeClass: Base
        localizableProperties: string[]
    }

    export class ColumnResize extends InstancePlugin {
        constructor(config?: Partial<ColumnResizeConfig>);
    }

    type ContextMenuConfig = {
        bubbleEvents: object
        cellItems: object[]
        disabled: boolean
        headerItems: object[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        processCellItems: Function
        processHeaderItems: Function
        triggerEvent: string
        onCellContextMenuBeforeShow: Function
        onCellContextMenuShow: Function
        onContextMenuItem: Function
        onContextMenuToggleItem: Function
        onHeaderContextMenuBeforeShow: Function
        onHeaderContextMenuShow: Function
    }

    export class ContextMenu extends InstancePlugin {
        onCellContextMenuBeforeShow: Function
        onCellContextMenuShow: Function
        onContextMenuItem: Function
        onContextMenuToggleItem: Function
        onHeaderContextMenuBeforeShow: Function
        onHeaderContextMenuShow: Function
        constructor(config?: Partial<ContextMenuConfig>);
    }

    type FilterConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        prioritizeColumns: boolean
    }

    export class Filter extends InstancePlugin {
        constructor(config?: Partial<FilterConfig>);
        closeFilterEditor(): void;
        showFilterEditor(column: Column|string, value?: any): void;
    }

    type FilterBarConfig = {
        bubbleEvents: object
        compactMode: boolean
        disabled: boolean
        keyStrokeFilterDelay: number
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        prioritizeColumns: boolean
    }

    export class FilterBar extends InstancePlugin {
        compactMode: boolean
        constructor(config?: Partial<FilterBarConfig>);
        getColumnFilterField(column: Column): Widget;
        hideFilterBar(): void;
        showFilterBar(): void;
        toggleFilterBar(): void;
    }

    export class GridFeatureManager {
        static getInstanceDefaultFeatures(instance: object): object;
        static getInstanceFeatures(instance: object): object;
        static getTypeNameDefaultFeatures(forType?: string): object;
        static getTypeNameFeatures(forType?: string): object;
        static isDefaultFeatureForInstance(featureClass: InstancePlugin, forType?: string): boolean;
        static isDefaultFeatureForTypeName(featureClass: InstancePlugin, forType?: string): boolean;
        static registerFeature(featureClass: Function, onByDefault?: boolean, forType?: string|string[]): void;
    }

    type GroupConfig = {
        bubbleEvents: object
        disabled: boolean
        field: string
        groupSortFn: Function
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        renderer: Function
        onToggleGroup: Function
    }

    export class Group extends InstancePlugin {
        onToggleGroup: Function
        constructor(config?: Partial<GroupConfig>);
        collapseAll(): void;
        expandAll(): void;
        toggleCollapse(recordOrId: Model|string, collapse: boolean): void;
    }

    type GridGroupSummaryConfig = {
        bubbleEvents: object
        collapseToHeader: boolean
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
    }

    export class GridGroupSummary extends InstancePlugin {
        constructor(config?: Partial<GridGroupSummaryConfig>);
        refresh(): void;
    }

    type HeaderMenuConfig = {
        bubbleEvents: object
        disabled: boolean
        items: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        menu: object
        menuConfig: object
        processItems: Function
        triggerEvent: string
        type: string
        onHeaderMenuBeforeShow: Function
        onHeaderMenuItem: Function
        onHeaderMenuShow: Function
        onHeaderMenuToggleItem: Function
    }

    export class HeaderMenu extends ContextMenuBase {
        onHeaderMenuBeforeShow: Function
        onHeaderMenuItem: Function
        onHeaderMenuShow: Function
        onHeaderMenuToggleItem: Function
        constructor(config?: Partial<HeaderMenuConfig>);
    }

    type QuickFindConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
    }

    export class QuickFind extends InstancePlugin {
        found: object[]
        foundCount: number
        constructor(config?: Partial<QuickFindConfig>);
        clear(): void;
        gotoFirstHit(): void;
        gotoHit(index: number): void;
        gotoLastHit(): void;
        gotoNextHit(): void;
        gotoPrevHit(): void;
        search(find: string, columnFieldOrId: string): void;
    }

    type RegionResizeConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
    }

    export class RegionResize extends InstancePlugin {
        constructor(config?: Partial<RegionResizeConfig>);
    }

    type RowCopyPasteConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        nameField: string
    }

    export class RowCopyPaste extends InstancePlugin {
        constructor(config?: Partial<RowCopyPasteConfig>);
        copyRows(isCut?: boolean): void;
        pasteRows(record?: object): void;
    }

    type RowReorderConfig = {
        bubbleEvents: object
        disabled: boolean
        hoverExpandTimeout: number
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        onGridRowAbort: Function
        onGridRowBeforeDragStart: Function
        onGridRowBeforeDropFinalize: Function
        onGridRowDrag: Function
        onGridRowDragStart: Function
        onGridRowDrop: Function
    }

    export class RowReorder extends InstancePlugin {
        onGridRowAbort: Function
        onGridRowBeforeDragStart: Function
        onGridRowBeforeDropFinalize: Function
        onGridRowDrag: Function
        onGridRowDragStart: Function
        onGridRowDrop: Function
        constructor(config?: Partial<RowReorderConfig>);
    }

    type SearchConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
    }

    export class Search extends InstancePlugin {
        foundCount: number
        isHitFocused: boolean
        constructor(config?: Partial<SearchConfig>);
        clear(): void;
        gotoFirstHit(): void;
        gotoHit(index: number): void;
        gotoLastHit(): void;
        gotoNextHit(): void;
        gotoPrevHit(): void;
        search(find: string, gotoHit?: boolean, reapply?: boolean): void;
    }

    type SortConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        multiSort: boolean
        prioritizeColumns: boolean
    }

    export class Sort extends InstancePlugin {
        constructor(config?: Partial<SortConfig>);
    }

    type StickyCellsConfig = {
        bubbleEvents: object
        contentSelector: string
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
    }

    export class StickyCells extends InstancePlugin {
        constructor(config?: Partial<StickyCellsConfig>);
    }

    type StripeConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
    }

    export class Stripe extends InstancePlugin {
        constructor(config?: Partial<StripeConfig>);
    }

    type GridSummaryConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        selectedOnly: boolean
    }

    export class GridSummary extends InstancePlugin {
        constructor(config?: Partial<GridSummaryConfig>);
        refresh(): void;
    }

    type TreeConfig = {
        bubbleEvents: object
        disabled: boolean
        expandOnCellClick: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
    }

    export class Tree extends InstancePlugin {
        constructor(config?: Partial<TreeConfig>);
        collapse(idOrRecord: string|number|Model): Promise<any>;
        collapseAll(): Promise<any>;
        expand(idOrRecord: string|number|Model): Promise<any>;
        expandAll(): Promise<any>;
        expandOrCollapseAll(collapse?: boolean, topNode?: Model): Promise<any>;
        expandTo(idOrRecord: string|number|Model): Promise<any>;
        toggleCollapse(idOrRecord: string|number|Model, collapse?: boolean, skipRefresh?: boolean): Promise<any>;
    }

    type GridExcelExporterConfig = {
        bubbleEvents: object
        convertEmptyValueToEmptyString: boolean
        dateFormat: string
        disabled: boolean
        exporterClass: TableExporter
        exporterConfig: object
        filename: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        zipcelx: object
    }

    export class GridExcelExporter extends InstancePlugin {
        constructor(config?: Partial<GridExcelExporterConfig>);
        export(config: object): void;
    }

    type GridPdfExportConfig = {
        alignRows: boolean
        bubbleEvents: object
        clientURL: string
        disabled: boolean
        exportDialog: object
        exportMask: string
        exportProgressMask: string
        exportServer: string
        exporterType: string
        exporters: Exporter[]
        fetchOptions: object
        fileFormat: string
        fileName: string
        footerTpl: Function
        headerTpl: Function
        keepPathName: boolean
        keepRegionSizes: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        openAfterExport: boolean
        openInNewTab: boolean
        orientation: string
        paperFormat: string
        repeatHeader: boolean
        rowsRange: string
        sendAsBinary: boolean
        showErrorToast: boolean
        translateURLsToAbsolute: boolean|string
        onBeforeExport: Function
        onExport: Function
        onExportStep: Function
    }

    export class GridPdfExport extends InstancePlugin {
        currentExportPromise: Promise<any>|null
        exportDialog: ExportDialog
        onBeforeExport: Function
        onExport: Function
        onExportStep: Function
        constructor(config?: Partial<GridPdfExportConfig>);
        export(config: object): Promise<any>;
        processExportContent(response: Response, config: object): Promise<any>;
        receiveExportContent(pages: object[], config: object): Promise<any>;
        showExportDialog(): Promise<any>;
    }

    type ExporterConfig = {
        bubbleEvents: object
        keepPathName: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        translateURLsToAbsolute: boolean|string
        onBeforeDestroy: Function
        onCatchAll: Function
        onDestroy: Function
    }

    export class Exporter implements Localizable, Events {
        localeManager: typeof LocaleManager
        stylesheets: string[]
        onBeforeDestroy: Function
        onCatchAll: Function
        onDestroy: Function
        constructor(config?: Partial<ExporterConfig>);
        static optionalL(text: string, templateData?: object): string;
        L(text: string, templateData?: object): string;
        addListener(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        hasListener(eventName: string): boolean;
        on(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        pageTpl(data: object): string;
        relayAll(through: Events, prefix: string, transformCase?: boolean): void;
        removeAllListeners(): void;
        removeListener(config: object, thisObj: object): void;
        resumeEvents(): void;
        suspendEvents(queue?: boolean): void;
        trigger(eventName: string, param?: object): boolean|Promise<any>;
        un(config: object, thisObj?: object): void;
        updateLocalization(): void;
    }

    type RowConfig = {
        cls: string|DomClassList|object
    }

    export class Row extends Base {
        bottom: number
        cells: HTMLElement[]
        cls: DomClassList|object
        dataIndex: number
        elements: HTMLElement[]
        height: number
        id: string|number
        index: number
        isFirst: boolean
        offsetHeight: number
        top: number
        constructor(config?: Partial<RowConfig>);
        addCls(classes: string|object|DomClassList): void;
        assignCls(classes: object): void;
        eachCell(fn: Function): void;
        eachElement(fn: Function): void;
        getCell(columnId: string|number): HTMLElement;
        getCells(region: string): HTMLElement[];
        getElement(region: string): HTMLElement;
        removeCls(classes: string|object|DomClassList): void;
    }

    type TableExporterConfig = {
        columns: string[]|object[]
        defaultColumnWidth: number
        exportDateAsInstance: boolean
        indent: boolean
        indentationSymbol: string
        showGroupHeader: boolean
        target: Grid
    }

    export class TableExporter extends Base {
        constructor(config?: Partial<TableExporterConfig>);
        export(config: object): object;
    }

    type GridFeaturesType = {
        cellEdit: GridCellEdit
        cellMenu: CellMenu
        cellTooltip: CellTooltip
        columnAutoWidth: ColumnAutoWidth
        columnDragToolbar: ColumnDragToolbar
        columnPicker: ColumnPicker
        columnReorder: ColumnReorder
        columnResize: ColumnResize
        contextMenu: ContextMenu
        excelExporter: GridExcelExporter
        filter: Filter
        filterBar: FilterBar
        group: Group
        groupSummary: GridGroupSummary
        headerMenu: HeaderMenu
        pdfExport: GridPdfExport
        quickFind: QuickFind
        regionResize: RegionResize
        rowCopyPaste: RowCopyPaste
        rowReorder: RowReorder
        search: Search
        sort: Sort
        stickyCells: StickyCells
        stripe: Stripe
        summary: GridSummary
        tree: Tree
    }

    type GridFeaturesConfigType = {
        cellEdit: string|boolean|Partial<GridCellEditConfig>
        cellMenu: string|boolean|Partial<CellMenuConfig>
        cellTooltip: string|boolean|Partial<CellTooltipConfig>
        columnAutoWidth: string|boolean|Partial<ColumnAutoWidthConfig>
        columnDragToolbar: string|boolean|Partial<ColumnDragToolbarConfig>
        columnPicker: string|boolean|Partial<ColumnPickerConfig>
        columnReorder: string|boolean|Partial<ColumnReorderConfig>
        columnResize: string|boolean|Partial<ColumnResizeConfig>
        contextMenu: string|boolean|Partial<ContextMenuConfig>
        excelExporter: string|boolean|Partial<GridExcelExporterConfig>
        filter: string|boolean|Partial<FilterConfig>
        filterBar: string|boolean|Partial<FilterBarConfig>
        group: string|boolean|Partial<GroupConfig>
        groupSummary: string|boolean|Partial<GridGroupSummaryConfig>
        headerMenu: string|boolean|Partial<HeaderMenuConfig>
        pdfExport: string|boolean|Partial<GridPdfExportConfig>
        quickFind: string|boolean|Partial<QuickFindConfig>
        regionResize: string|boolean|Partial<RegionResizeConfig>
        rowCopyPaste: string|boolean|Partial<RowCopyPasteConfig>
        rowReorder: string|boolean|Partial<RowReorderConfig>
        search: string|boolean|Partial<SearchConfig>
        sort: string|boolean|Partial<SortConfig>
        stickyCells: string|boolean|Partial<StickyCellsConfig>
        stripe: string|boolean|Partial<StripeConfig>
        summary: string|boolean|Partial<GridSummaryConfig>
        tree: string|boolean|Partial<TreeConfig>
    }

    type GridConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        animateRemovingRows: boolean
        appendTo: HTMLElement|string
        autoHeight: boolean
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        centered: boolean
        cls: string|object
        columnLines: boolean
        columns: object[]|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        contextMenuTriggerEvent: string
        data: object[]
        dataset: object
        defaultBindProperty: string
        defaultRegion: string
        defaults: object
        destroyStore: boolean
        disableGridRowModelWarning: boolean
        disabled: boolean
        dock: string
        draggable: boolean|object
        emptyText: string
        enableSticky: boolean
        enableTextSelection: boolean
        enableUndoRedoKeys: boolean
        features: Partial<GridFeaturesConfigType>
        fillLastColumn: boolean
        fixedRowHeight: boolean
        flex: number|string
        floating: boolean
        footer: object|string
        fullRowRefresh: boolean
        getRowHeight: Function
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideHeaders: boolean
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        loadMask: string|object|null
        loadMaskDefaults: object|Mask|Partial<MaskConfig>
        loadMaskError: object|Mask|Partial<MaskConfig>
        localeClass: Base
        localizableProperties: string[]
        longPressTime: number
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        plugins: Function[]
        positioned: boolean
        preserveFocusOnDatasetChange: boolean
        preserveScrollOnDatasetChange: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        resizeToFitIncludesHeader: boolean
        responsiveLevels: object
        ripple: boolean|object
        rootElement: ShadowRoot
        rowHeight: number
        scrollAction: string
        scrollManager: object|ScrollManager|Partial<ScrollManagerConfig>
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        scrollerClass: Scroller
        selectionMode: object
        showAnimation: boolean|object
        showDirty: boolean
        showRemoveRowInContextMenu: boolean
        store: Store|object|Partial<StoreConfig>
        strips: object
        style: string
        subGridConfigs: object
        syncMask: string|object|null
        tab: boolean|object
        tag: string
        tbar: object[]|object
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        transitionDuration: number
        trapFocus: boolean
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class Grid extends GridBase {
        features: GridFeaturesType
        constructor(config?: Partial<GridConfig>);
    }

    type GridBaseFeaturesType = {
        cellEdit: GridCellEdit
        cellMenu: CellMenu
        cellTooltip: CellTooltip
        columnAutoWidth: ColumnAutoWidth
        columnDragToolbar: ColumnDragToolbar
        columnPicker: ColumnPicker
        columnReorder: ColumnReorder
        columnResize: ColumnResize
        contextMenu: ContextMenu
        excelExporter: GridExcelExporter
        filter: Filter
        filterBar: FilterBar
        group: Group
        groupSummary: GridGroupSummary
        headerMenu: HeaderMenu
        pdfExport: GridPdfExport
        quickFind: QuickFind
        regionResize: RegionResize
        rowCopyPaste: RowCopyPaste
        rowReorder: RowReorder
        search: Search
        sort: Sort
        stickyCells: StickyCells
        stripe: Stripe
        summary: GridSummary
        tree: Tree
    }

    type GridBaseFeaturesConfigType = {
        cellEdit: string|boolean|Partial<GridCellEditConfig>
        cellMenu: string|boolean|Partial<CellMenuConfig>
        cellTooltip: string|boolean|Partial<CellTooltipConfig>
        columnAutoWidth: string|boolean|Partial<ColumnAutoWidthConfig>
        columnDragToolbar: string|boolean|Partial<ColumnDragToolbarConfig>
        columnPicker: string|boolean|Partial<ColumnPickerConfig>
        columnReorder: string|boolean|Partial<ColumnReorderConfig>
        columnResize: string|boolean|Partial<ColumnResizeConfig>
        contextMenu: string|boolean|Partial<ContextMenuConfig>
        excelExporter: string|boolean|Partial<GridExcelExporterConfig>
        filter: string|boolean|Partial<FilterConfig>
        filterBar: string|boolean|Partial<FilterBarConfig>
        group: string|boolean|Partial<GroupConfig>
        groupSummary: string|boolean|Partial<GridGroupSummaryConfig>
        headerMenu: string|boolean|Partial<HeaderMenuConfig>
        pdfExport: string|boolean|Partial<GridPdfExportConfig>
        quickFind: string|boolean|Partial<QuickFindConfig>
        regionResize: string|boolean|Partial<RegionResizeConfig>
        rowCopyPaste: string|boolean|Partial<RowCopyPasteConfig>
        rowReorder: string|boolean|Partial<RowReorderConfig>
        search: string|boolean|Partial<SearchConfig>
        sort: string|boolean|Partial<SortConfig>
        stickyCells: string|boolean|Partial<StickyCellsConfig>
        stripe: string|boolean|Partial<StripeConfig>
        summary: string|boolean|Partial<GridSummaryConfig>
        tree: string|boolean|Partial<TreeConfig>
    }

    type GridBaseConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        animateRemovingRows: boolean
        appendTo: HTMLElement|string
        autoHeight: boolean
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        centered: boolean
        cls: string|object
        columnLines: boolean
        columns: object[]|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        contextMenuTriggerEvent: string
        data: object[]
        dataset: object
        defaultBindProperty: string
        defaultRegion: string
        defaults: object
        destroyStore: boolean
        disableGridRowModelWarning: boolean
        disabled: boolean
        dock: string
        draggable: boolean|object
        emptyText: string
        enableSticky: boolean
        enableTextSelection: boolean
        enableUndoRedoKeys: boolean
        features: Partial<GridBaseFeaturesConfigType>
        fillLastColumn: boolean
        fixedRowHeight: boolean
        flex: number|string
        floating: boolean
        footer: object|string
        fullRowRefresh: boolean
        getRowHeight: Function
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideHeaders: boolean
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        loadMask: string|object|null
        loadMaskDefaults: object|Mask|Partial<MaskConfig>
        loadMaskError: object|Mask|Partial<MaskConfig>
        localeClass: Base
        localizableProperties: string[]
        longPressTime: number
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        plugins: Function[]
        positioned: boolean
        preserveFocusOnDatasetChange: boolean
        preserveScrollOnDatasetChange: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        resizeToFitIncludesHeader: boolean
        responsiveLevels: object
        ripple: boolean|object
        rootElement: ShadowRoot
        rowHeight: number
        scrollAction: string
        scrollManager: object|ScrollManager|Partial<ScrollManagerConfig>
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        scrollerClass: Scroller
        selectionMode: object
        showAnimation: boolean|object
        showDirty: boolean
        showRemoveRowInContextMenu: boolean
        store: Store|object|Partial<StoreConfig>
        strips: object
        style: string
        subGridConfigs: object
        syncMask: string|object|null
        tab: boolean|object
        tag: string
        tbar: object[]|object
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        transitionDuration: number
        trapFocus: boolean
        weight: number
        width: string|number
        x: number
        y: number
        onBeforeCellEditStart: Function
        onBeforeDestroy: Function
        onBeforeExport: Function
        onBeforeFinishCellEdit: Function
        onBeforeRenderRows: Function
        onBeforeToggleNode: Function
        onCancelCellEdit: Function
        onCatchAll: Function
        onCellClick: Function
        onCellContextMenu: Function
        onCellContextMenuBeforeShow: Function
        onCellContextMenuShow: Function
        onCellDblClick: Function
        onCellMenuBeforeShow: Function
        onCellMenuItem: Function
        onCellMenuShow: Function
        onCellMenuToggleItem: Function
        onCellMouseOut: Function
        onCellMouseOver: Function
        onCollapseNode: Function
        onContextMenuItem: Function
        onContextMenuToggleItem: Function
        onDestroy: Function
        onExpandNode: Function
        onExport: Function
        onFinishCellEdit: Function
        onHeaderContextMenuBeforeShow: Function
        onHeaderContextMenuShow: Function
        onHeaderMenuBeforeShow: Function
        onHeaderMenuItem: Function
        onHeaderMenuShow: Function
        onHeaderMenuToggleItem: Function
        onMouseOut: Function
        onMouseOver: Function
        onRenderRows: Function
        onResponsive: Function
        onScroll: Function
        onSelectionChange: Function
        onStartCellEdit: Function
        onToggleNode: Function
    }

    export class GridBase extends Panel implements Pluggable, State, GridElementEvents, GridFeatures, GridResponsive, GridSelection, GridState, GridSubGrids, LoadMaskable {
        bodyHeight: number
        columnLines: boolean
        columns: ColumnStore
        data: object[]
        features: GridBaseFeaturesType
        firstVisibleRow: Row
        headerHeight: number
        lastVisibleRow: Row
        localeManager: typeof LocaleManager
        plugins: object
        readOnly: boolean
        responsiveLevel: string
        rowHeight: number
        scrollManager: ScrollManager
        selectedCell: object
        selectedCellCSSSelector: string
        selectedRecord: Model
        selectedRecords: Model[]|number[]
        state: object
        store: Store|object|Partial<StoreConfig>
        subGrids: object
        transitionDuration: number
        onBeforeCellEditStart: Function
        onBeforeDestroy: Function
        onBeforeExport: Function
        onBeforeFinishCellEdit: Function
        onBeforeRenderRows: Function
        onBeforeToggleNode: Function
        onCancelCellEdit: Function
        onCatchAll: Function
        onCellClick: Function
        onCellContextMenu: Function
        onCellContextMenuBeforeShow: Function
        onCellContextMenuShow: Function
        onCellDblClick: Function
        onCellMenuBeforeShow: Function
        onCellMenuItem: Function
        onCellMenuShow: Function
        onCellMenuToggleItem: Function
        onCellMouseOut: Function
        onCellMouseOver: Function
        onCollapseNode: Function
        onContextMenuItem: Function
        onContextMenuToggleItem: Function
        onDestroy: Function
        onExpandNode: Function
        onExport: Function
        onFinishCellEdit: Function
        onHeaderContextMenuBeforeShow: Function
        onHeaderContextMenuShow: Function
        onHeaderMenuBeforeShow: Function
        onHeaderMenuItem: Function
        onHeaderMenuShow: Function
        onHeaderMenuToggleItem: Function
        onMouseOut: Function
        onMouseOver: Function
        onRenderRows: Function
        onResponsive: Function
        onScroll: Function
        onSelectionChange: Function
        onStartCellEdit: Function
        onToggleNode: Function
        constructor(config?: Partial<GridBaseConfig>);
        static optionalL(text: string, templateData?: object): string;
        L(text: string, templateData?: object): string;
        addListener(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        addPlugins(plugins: Function[]): void;
        collapse(idOrRecord: string|number|Model): Promise<any>;
        collapseAll(): void;
        copyRows(isCut?: boolean): void;
        deselectAll(removeCurrentRecordsOnly?: boolean): void;
        deselectCell(cellSelector: object): object;
        deselectRow(recordOrId: Model|string|number): void;
        deselectRows(recordOrIds: Model|string|number|Model[]|string[]|number[]): void;
        disableScrollingCloseToEdges(subGrid: SubGrid|string): void;
        enableScrollingCloseToEdges(subGrid: SubGrid|string): void;
        expand(idOrRecord: string|number|Model): Promise<any>;
        expandAll(): void;
        expandTo(idOrRecord: string|number|Model): Promise<any>;
        getCell(cellContext: object): HTMLElement;
        getColumnFromElement(element: HTMLElement): Column;
        getHeaderElement(columnId: string|number|Column): HTMLElement;
        getPlugin(pluginClassOrName: string|Function): object;
        getRecordFromElement(element: HTMLElement): Model;
        getSubGrid(region: string): SubGrid;
        getSubGridFromColumn(column: string|Column): SubGrid;
        hasFeature(name: string): boolean;
        hasListener(eventName: string): boolean;
        hasPlugin(pluginClassOrName: string|Function): boolean;
        isSelectable(recordCellOrId: Model|object|string|number|Partial<ModelConfig>): boolean;
        isSelected(cellSelectorOrId: object|string|number|Model|Partial<ModelConfig>): boolean;
        maskBody(loadMask: string): Mask;
        on(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        pasteRows(record?: object): void;
        refreshColumn(column: Column): void;
        refreshRows(): void;
        relayAll(through: Events, prefix: string, transformCase?: boolean): void;
        removeAllListeners(): void;
        removeListener(config: object, thisObj: object): void;
        renderContents(): void;
        renderRows(): void;
        restoreScroll(state?: object): void;
        resumeEvents(): void;
        scrollCellIntoView(cellContext: object): void;
        scrollColumnIntoView(column: Column|string|number, options?: object): Promise<any>;
        scrollRowIntoView(recordOrId: Model|string|number, options?: object): Promise<any>;
        scrollToBottom(): Promise<any>;
        scrollToTop(): Promise<any>;
        selectAll(): void;
        selectCell(cellSelector: object, scrollIntoView?: boolean, addToSelection?: boolean, silent?: boolean): object;
        selectRange(fromId: string|number, toId: string|number): void;
        selectRow(options: object|Model|Partial<ModelConfig>): void;
        selectRows(recordOrIds: Model|string|number|Model[]|string[]|number[], addToSelection?: boolean): void;
        showContextMenu(event: Event, alignSpec?: object|HTMLElement): void;
        spliceSelectedRecords(index: number, toRemove: object[]|number, toAdd: object[]|object): void;
        startEditing(cellContext: object): boolean;
        storeScroll(): object;
        suspendEvents(queue?: boolean): void;
        toggleCollapse(idOrRecord: string|number|Model, collapse?: boolean, skipRefresh?: boolean): Promise<any>;
        trigger(eventName: string, param?: object): boolean|Promise<any>;
        un(config: object, thisObj?: object): void;
        unmaskBody(): void;
        updateLocalization(): void;
    }

    type SubGridConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        collapsed: boolean
        columns: ColumnStore
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        region: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class SubGrid extends Widget {
        collapsed: boolean
        flex: number|string
        rowElements: HTMLElement[]
        viewRectangle: Rectangle
        width: number
        constructor(config?: Partial<SubGridConfig>);
        collapse(): Promise<any>;
        expand(): Promise<any>;
        resizeColumnsToFitContent(): void;
        scrollColumnIntoView(column: Column|string|number, options?: object): Promise<any>;
    }

    type TreeGridFeaturesType = {
        cellEdit: GridCellEdit
        cellMenu: CellMenu
        cellTooltip: CellTooltip
        columnAutoWidth: ColumnAutoWidth
        columnDragToolbar: ColumnDragToolbar
        columnPicker: ColumnPicker
        columnReorder: ColumnReorder
        columnResize: ColumnResize
        contextMenu: ContextMenu
        excelExporter: GridExcelExporter
        filter: Filter
        filterBar: FilterBar
        group: Group
        groupSummary: GridGroupSummary
        headerMenu: HeaderMenu
        pdfExport: GridPdfExport
        quickFind: QuickFind
        regionResize: RegionResize
        rowCopyPaste: RowCopyPaste
        rowReorder: RowReorder
        search: Search
        sort: Sort
        stickyCells: StickyCells
        stripe: Stripe
        summary: GridSummary
        tree: Tree
    }

    type TreeGridFeaturesConfigType = {
        cellEdit: string|boolean|Partial<GridCellEditConfig>
        cellMenu: string|boolean|Partial<CellMenuConfig>
        cellTooltip: string|boolean|Partial<CellTooltipConfig>
        columnAutoWidth: string|boolean|Partial<ColumnAutoWidthConfig>
        columnDragToolbar: string|boolean|Partial<ColumnDragToolbarConfig>
        columnPicker: string|boolean|Partial<ColumnPickerConfig>
        columnReorder: string|boolean|Partial<ColumnReorderConfig>
        columnResize: string|boolean|Partial<ColumnResizeConfig>
        contextMenu: string|boolean|Partial<ContextMenuConfig>
        excelExporter: string|boolean|Partial<GridExcelExporterConfig>
        filter: string|boolean|Partial<FilterConfig>
        filterBar: string|boolean|Partial<FilterBarConfig>
        group: string|boolean|Partial<GroupConfig>
        groupSummary: string|boolean|Partial<GridGroupSummaryConfig>
        headerMenu: string|boolean|Partial<HeaderMenuConfig>
        pdfExport: string|boolean|Partial<GridPdfExportConfig>
        quickFind: string|boolean|Partial<QuickFindConfig>
        regionResize: string|boolean|Partial<RegionResizeConfig>
        rowCopyPaste: string|boolean|Partial<RowCopyPasteConfig>
        rowReorder: string|boolean|Partial<RowReorderConfig>
        search: string|boolean|Partial<SearchConfig>
        sort: string|boolean|Partial<SortConfig>
        stickyCells: string|boolean|Partial<StickyCellsConfig>
        stripe: string|boolean|Partial<StripeConfig>
        summary: string|boolean|Partial<GridSummaryConfig>
        tree: string|boolean|Partial<TreeConfig>
    }

    type TreeGridConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        animateRemovingRows: boolean
        appendTo: HTMLElement|string
        autoHeight: boolean
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        centered: boolean
        cls: string|object
        columnLines: boolean
        columns: object[]|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        contextMenuTriggerEvent: string
        data: object[]
        dataset: object
        defaultBindProperty: string
        defaultRegion: string
        defaults: object
        destroyStore: boolean
        disableGridRowModelWarning: boolean
        disabled: boolean
        dock: string
        draggable: boolean|object
        emptyText: string
        enableSticky: boolean
        enableTextSelection: boolean
        enableUndoRedoKeys: boolean
        features: Partial<TreeGridFeaturesConfigType>
        fillLastColumn: boolean
        fixedRowHeight: boolean
        flex: number|string
        floating: boolean
        footer: object|string
        fullRowRefresh: boolean
        getRowHeight: Function
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideHeaders: boolean
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        loadMask: string|object|null
        loadMaskDefaults: object|Mask|Partial<MaskConfig>
        loadMaskError: object|Mask|Partial<MaskConfig>
        localeClass: Base
        localizableProperties: string[]
        longPressTime: number
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        plugins: Function[]
        positioned: boolean
        preserveFocusOnDatasetChange: boolean
        preserveScrollOnDatasetChange: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        resizeToFitIncludesHeader: boolean
        responsiveLevels: object
        ripple: boolean|object
        rootElement: ShadowRoot
        rowHeight: number
        scrollAction: string
        scrollManager: object|ScrollManager|Partial<ScrollManagerConfig>
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        scrollerClass: Scroller
        selectionMode: object
        showAnimation: boolean|object
        showDirty: boolean
        showRemoveRowInContextMenu: boolean
        store: Store|object|Partial<StoreConfig>
        strips: object
        style: string
        subGridConfigs: object
        syncMask: string|object|null
        tab: boolean|object
        tag: string
        tbar: object[]|object
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        transitionDuration: number
        trapFocus: boolean
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class TreeGrid extends Grid {
        features: TreeGridFeaturesType
        constructor(config?: Partial<TreeGridConfig>);
        collapse(idOrRecord: string|number|Model): Promise<any>;
        expand(idOrRecord: string|number|Model): Promise<any>;
        expandTo(idOrRecord: string|number|Model): Promise<any>;
        toggleCollapse(idOrRecord: string|number|Model, collapse?: boolean, skipRefresh?: boolean): Promise<any>;
    }

    type ExportDialogConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoSelectVisibleColumns: boolean
        autoShow: boolean
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        centered: boolean
        client: Grid
        closable: boolean
        closeAction: string
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hidePNGMultipageOption: boolean
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maximizable: boolean
        maximized: boolean
        minHeight: string|number
        minWidth: string|number
        modal: boolean
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showOnClick: boolean
        strips: object
        style: string
        tab: boolean|object
        tag: string
        tbar: object[]|object
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        trapFocus: boolean
        weight: number
        width: string|number
        x: number
        y: number
        onCancel: Function
        onExport: Function
    }

    export class ExportDialog extends Popup {
        values: object
        onCancel: Function
        onExport: Function
        constructor(config?: Partial<ExportDialogConfig>);
    }

    type GridElementEventsConfig = {
        enableUndoRedoKeys: boolean
        longPressTime: number
        onCellClick: Function
        onCellContextMenu: Function
        onCellDblClick: Function
        onCellMouseOut: Function
        onCellMouseOver: Function
        onMouseOut: Function
        onMouseOver: Function
    }

    export class GridElementEvents {
        onCellClick: Function
        onCellContextMenu: Function
        onCellDblClick: Function
        onCellMouseOut: Function
        onCellMouseOver: Function
        onMouseOut: Function
        onMouseOver: Function
        constructor(config?: Partial<GridElementEventsConfig>);
    }

    type GridFeaturesConfig = {
        features: object
    }

    export class GridFeatures {
        features: object
        constructor(config?: Partial<GridFeaturesConfig>);
        hasFeature(name: string): boolean;
    }

    type GridResponsiveConfig = {
        responsiveLevels: object
        onResponsive: Function
    }

    export class GridResponsive {
        responsiveLevel: string
        onResponsive: Function
        constructor(config?: Partial<GridResponsiveConfig>);
    }

    type GridSelectionConfig = {
        selectionMode: object
        onSelectionChange: Function
    }

    export class GridSelection {
        selectedCell: object
        selectedCellCSSSelector: string
        selectedRecord: Model
        selectedRecords: Model[]|number[]
        onSelectionChange: Function
        constructor(config?: Partial<GridSelectionConfig>);
        deselectAll(removeCurrentRecordsOnly?: boolean): void;
        deselectCell(cellSelector: object): object;
        deselectRow(recordOrId: Model|string|number): void;
        deselectRows(recordOrIds: Model|string|number|Model[]|string[]|number[]): void;
        isSelectable(recordCellOrId: Model|object|string|number|Partial<ModelConfig>): boolean;
        isSelected(cellSelectorOrId: object|string|number|Model|Partial<ModelConfig>): boolean;
        selectAll(): void;
        selectCell(cellSelector: object, scrollIntoView?: boolean, addToSelection?: boolean, silent?: boolean): object;
        selectRange(fromId: string|number, toId: string|number): void;
        selectRow(options: object|Model|Partial<ModelConfig>): void;
        selectRows(recordOrIds: Model|string|number|Model[]|string[]|number[], addToSelection?: boolean): void;
        spliceSelectedRecords(index: number, toRemove: object[]|number, toAdd: object[]|object): void;
    }

    export class GridState {
        state: object
    }

    export class GridSubGrids {
        subGrids: object
        getSubGrid(region: string): SubGrid;
        getSubGridFromColumn(column: string|Column): SubGrid;
    }

    type ResourceCollapseColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class ResourceCollapseColumn extends Column {
        constructor(config?: Partial<ResourceCollapseColumnConfig>);
    }

    type ResourceInfoColumnConfig = {
        align: string
        autoHeight: boolean
        autoScaleThreshold: number
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        showEventCount: boolean
        showImage: boolean
        showMeta: Function
        showRole: boolean|string
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        validNames: string[]
        width: number|string
    }

    export class ResourceInfoColumn extends Column {
        constructor(config?: Partial<ResourceInfoColumnConfig>);
    }

    type SchedulerTimeAxisColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
        onTimeAxisHeaderClick: Function
        onTimeAxisHeaderContextMenu: Function
        onTimeAxisHeaderDblClick: Function
    }

    export class SchedulerTimeAxisColumn extends Column {
        onTimeAxisHeaderClick: Function
        onTimeAxisHeaderContextMenu: Function
        onTimeAxisHeaderDblClick: Function
        constructor(config?: Partial<SchedulerTimeAxisColumnConfig>);
        refreshHeader(): void;
    }

    type AbstractCrudManagerConfig = {
        autoLoad: boolean
        autoSync: boolean
        autoSyncTimeout: number
        bubbleEvents: object
        crudStores: Store[]|string[]|object[]|Partial<StoreConfig>[]
        listeners: object
        phantomIdField: string
        phantomParentIdField: string
        resetIdsBeforeSync: boolean
        skipSuccessProperty: boolean
        storeIdProperty: string
        stores: Store[]|string[]|object[]|Partial<StoreConfig>[]
        supportShortSyncResponse: boolean
        syncApplySequence: string[]
        trackResponseType: boolean
        validateResponse: boolean
        writeAllFields: boolean
        onBeforeDestroy: Function
        onBeforeLoad: Function
        onBeforeLoadApply: Function
        onBeforeResponseApply: Function
        onBeforeSync: Function
        onBeforeSyncApply: Function
        onCatchAll: Function
        onDestroy: Function
        onHasChanges: Function
        onLoad: Function
        onLoadCanceled: Function
        onLoadFail: Function
        onNoChanges: Function
        onRequestDone: Function
        onRequestFail: Function
        onSync: Function
        onSyncCanceled: Function
        onSyncDelayed: Function
        onSyncFail: Function
    }

    export abstract class AbstractCrudManager extends Base implements AbstractCrudManagerMixin {
        changes: object
        crudRevision: number
        crudStores: object[]
        inlineData: object
        isCrudManagerLoading: boolean
        isCrudManagerSyncing: boolean
        isLoading: boolean
        json: string
        revision: number
        stores: object[]
        syncApplySequence: object[]
        onBeforeDestroy: Function
        onBeforeLoad: Function
        onBeforeLoadApply: Function
        onBeforeResponseApply: Function
        onBeforeSync: Function
        onBeforeSyncApply: Function
        onCatchAll: Function
        onDestroy: Function
        onHasChanges: Function
        onLoad: Function
        onLoadCanceled: Function
        onLoadFail: Function
        onNoChanges: Function
        onRequestDone: Function
        onRequestFail: Function
        onSync: Function
        onSyncCanceled: Function
        onSyncDelayed: Function
        onSyncFail: Function
        constructor(config?: Partial<AbstractCrudManagerConfig>);
        acceptChanges(): void;
        addCrudStore(store: Store|string|object|Store[]|string[]|object[]|Partial<StoreConfig>|Partial<StoreConfig>[], position?: number, fromStore?: string|Store|object|Partial<StoreConfig>): void;
        addListener(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        addStore(store: Store|string|object|Store[]|string[]|object[]|Partial<StoreConfig>|Partial<StoreConfig>[], position?: number, fromStore?: string|Store|object|Partial<StoreConfig>): void;
        addStoreToApplySequence(store: Store|object|Store[]|object[]|Partial<StoreConfig>|Partial<StoreConfig>[], position?: number, fromStore?: string|Store|object|Partial<StoreConfig>): void;
        abstract cancelRequest(promise: Promise<any>, reject: Function): void;
        commit(): void;
        commitCrudStores(): void;
        crudStoreHasChanges(storeId?: string|Store): boolean;
        abstract decode(response: string): object;
        doDestroy(): void;
        abstract encode(request: object): string;
        getCrudStore(storeId: string): Store;
        getStoreDescriptor(storeId: string|Store): object;
        hasListener(eventName: string): boolean;
        load(options?: object): Promise<any>;
        loadCrudManagerData(response: object, options?: object): void;
        on(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        reject(): void;
        rejectCrudStores(): void;
        relayAll(through: Events, prefix: string, transformCase?: boolean): void;
        removeAllListeners(): void;
        removeCrudStore(store: object|string|Store|Partial<StoreConfig>): void;
        removeListener(config: object, thisObj: object): void;
        removeStoreFromApplySequence(store: object|string|Store|Partial<StoreConfig>): void;
        resumeAutoSync(doSync?: boolean): void;
        resumeEvents(): void;
        revertChanges(): void;
        abstract sendRequest(request: object): Promise<any>;
        suspendAutoSync(): void;
        suspendEvents(queue?: boolean): void;
        sync(): Promise<any>;
        toJSON(): object;
        trigger(eventName: string, param?: object): boolean|Promise<any>;
        un(config: object, thisObj?: object): void;
    }

    type AbstractCrudManagerMixinConfig = {
        autoLoad: boolean
        autoSync: boolean
        autoSyncTimeout: number
        bubbleEvents: object
        crudStores: Store[]|string[]|object[]|Partial<StoreConfig>[]
        listeners: object
        phantomIdField: string
        phantomParentIdField: string
        resetIdsBeforeSync: boolean
        skipSuccessProperty: boolean
        storeIdProperty: string
        supportShortSyncResponse: boolean
        syncApplySequence: string[]
        trackResponseType: boolean
        validateResponse: boolean
        writeAllFields: boolean
        onBeforeDestroy: Function
        onBeforeLoad: Function
        onBeforeLoadApply: Function
        onBeforeResponseApply: Function
        onBeforeSync: Function
        onBeforeSyncApply: Function
        onCatchAll: Function
        onDestroy: Function
        onHasChanges: Function
        onLoad: Function
        onLoadCanceled: Function
        onLoadFail: Function
        onNoChanges: Function
        onRequestDone: Function
        onRequestFail: Function
        onSync: Function
        onSyncCanceled: Function
        onSyncDelayed: Function
        onSyncFail: Function
    }

    export abstract class AbstractCrudManagerMixin implements Delayable, Events, AbstractCrudManagerValidation {
        changes: object
        crudRevision: number
        crudStores: object[]
        isCrudManagerLoading: boolean
        isCrudManagerSyncing: boolean
        syncApplySequence: object[]
        onBeforeDestroy: Function
        onBeforeLoad: Function
        onBeforeLoadApply: Function
        onBeforeResponseApply: Function
        onBeforeSync: Function
        onBeforeSyncApply: Function
        onCatchAll: Function
        onDestroy: Function
        onHasChanges: Function
        onLoad: Function
        onLoadCanceled: Function
        onLoadFail: Function
        onNoChanges: Function
        onRequestDone: Function
        onRequestFail: Function
        onSync: Function
        onSyncCanceled: Function
        onSyncDelayed: Function
        onSyncFail: Function
        constructor(config?: Partial<AbstractCrudManagerMixinConfig>);
        acceptChanges(): void;
        addCrudStore(store: Store|string|object|Store[]|string[]|object[]|Partial<StoreConfig>|Partial<StoreConfig>[], position?: number, fromStore?: string|Store|object|Partial<StoreConfig>): void;
        addListener(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        addStoreToApplySequence(store: Store|object|Store[]|object[]|Partial<StoreConfig>|Partial<StoreConfig>[], position?: number, fromStore?: string|Store|object|Partial<StoreConfig>): void;
        abstract cancelRequest(promise: Promise<any>, reject: Function): void;
        commitCrudStores(): void;
        crudStoreHasChanges(storeId?: string|Store): boolean;
        abstract decode(response: string): object;
        doDestroy(): void;
        abstract encode(request: object): string;
        getCrudStore(storeId: string): Store;
        getStoreDescriptor(storeId: string|Store): object;
        hasListener(eventName: string): boolean;
        load(options?: object): Promise<any>;
        loadCrudManagerData(response: object, options?: object): void;
        on(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        rejectCrudStores(): void;
        relayAll(through: Events, prefix: string, transformCase?: boolean): void;
        removeAllListeners(): void;
        removeCrudStore(store: object|string|Store|Partial<StoreConfig>): void;
        removeListener(config: object, thisObj: object): void;
        removeStoreFromApplySequence(store: object|string|Store|Partial<StoreConfig>): void;
        resumeAutoSync(doSync?: boolean): void;
        resumeEvents(): void;
        revertChanges(): void;
        abstract sendRequest(request: object): Promise<any>;
        suspendAutoSync(): void;
        suspendEvents(queue?: boolean): void;
        sync(): Promise<any>;
        trigger(eventName: string, param?: object): boolean|Promise<any>;
        un(config: object, thisObj?: object): void;
    }

    type JsonEncoderConfig = {
        encoder: object
    }

    export class JsonEncoder {
        constructor(config?: Partial<JsonEncoderConfig>);
        decode(responseText: string): object;
        encode(requestData: object): string;
    }

    type AbstractCrudManagerValidationConfig = {
        skipSuccessProperty: boolean
        validateResponse: boolean
    }

    export class AbstractCrudManagerValidation {
        constructor(config?: Partial<AbstractCrudManagerValidationConfig>);
    }

    type CrudManagerViewConfig = {
        loadMask: string|object|null
        loadMaskDefaults: object|Mask|Partial<MaskConfig>
        loadMaskError: object|Mask|Partial<MaskConfig>
        syncMask: string|object|null
    }

    export class CrudManagerView extends LoadMaskable {
        constructor(config?: Partial<CrudManagerViewConfig>);
    }

    type AjaxTransportConfig = {
        transport: object
        onBeforeSend: Function
    }

    export abstract class AjaxTransport {
        onBeforeSend: Function
        constructor(config?: Partial<AjaxTransportConfig>);
        cancelRequest(requestPromise: Promise<any>): void;
        sendRequest(request: object): Promise<any>;
    }

    type TimelineBaseTagConfig = {
        faPath: string
        stylesheet: string
    }

    export abstract class TimelineBaseTag extends WidgetTag {
        constructor(config?: Partial<TimelineBaseTagConfig>);
    }

    type SchedulerAssignmentStoreConfig = {
        allowNoId: boolean
        autoCommit: boolean
        autoLoad: boolean
        autoTree: boolean
        bubbleEvents: object
        chainedFields: string[]
        chainedFilterFn: Function
        createUrl: string
        data: object[]|Model[]|Partial<ModelConfig>[]
        deleteUrl: string
        doRelayToMaster: string[]
        dontRelayToMaster: string
        fetchOptions: object
        fields: string[]|object[]|DataField[]|Partial<DataFieldConfig>[]
        filterParamName: string
        filters: object|object[]
        groupers: object[]
        headers: object
        httpMethods: object
        id: string|number
        keepUncommittedChanges: boolean
        listeners: object
        masterStore: Store
        modelClass: typeof Model
        pageParamName: string
        pageSize: number
        pageSizeParamName: string
        pageStartParamName: string
        params: object
        parentIdParamName: string
        readUrl: string
        reapplyFilterOnAdd: boolean
        reapplyFilterOnUpdate: boolean
        reapplySortersOnAdd: boolean
        responseDataProperty: string
        responseSuccessProperty: string
        responseTotalProperty: string
        restfulFilter: boolean
        sendAsFormData: boolean
        sortParamName: string
        sorters: object[]|string[]
        stm: StateTrackingManager
        storage: Collection|object|Partial<CollectionConfig>
        syncDataOnLoad: boolean|object
        transformFlatData: boolean
        tree: boolean
        updateUrl: string
        useLocaleSort: boolean|string|object
        useRawData: boolean|object
        useRestfulMethods: boolean
        writeAllFields: boolean
    }

    export class SchedulerAssignmentStore extends AjaxStore implements AssignmentStoreMixin, SchedulerPartOfProject {
        assignmentStore: SchedulerAssignmentStore
        data: object[]
        dependencyStore: SchedulerDependencyStore
        eventStore: SchedulerEventStore
        project: SchedulerProjectModel
        resourceStore: SchedulerResourceStore
        constructor(config?: Partial<SchedulerAssignmentStoreConfig>);
        add(records: SchedulerAssignmentModel|SchedulerAssignmentModel[]|object|object[]|Partial<SchedulerAssignmentModelConfig>|Partial<SchedulerAssignmentModelConfig>[], silent?: boolean): SchedulerAssignmentModel[];
        addAsync(records: SchedulerAssignmentModel|SchedulerAssignmentModel[]|object|object[]|Partial<SchedulerAssignmentModelConfig>|Partial<SchedulerAssignmentModelConfig>[], silent?: boolean): SchedulerAssignmentModel[];
        assignEventToResource(event: TimeSpan, resources: SchedulerResourceModel|SchedulerResourceModel[], assignmentSetupFn?: Function, removeExistingAssignments?: boolean): SchedulerAssignmentModel[];
        getAssignmentForEventAndResource(event: SchedulerEventModel|string|number, resource: SchedulerResourceModel|string|number): SchedulerAssignmentModel;
        getAssignmentsForEvent(event: TimeSpan): SchedulerAssignmentModel[];
        getAssignmentsForResource(resource: SchedulerResourceModel): SchedulerAssignmentModel[];
        getEventsForResource(resource: SchedulerResourceModel|string|number): TimeSpan[];
        getResourcesForEvent(event: SchedulerEventModel): SchedulerResourceModel[];
        isEventAssignedToResource(event: SchedulerEventModel|string|number, resource: SchedulerResourceModel|string|number): boolean;
        loadDataAsync(data: object[]): void;
        mapAssignmentsForEvent(event: SchedulerEventModel, fn?: Function, filterFn?: Function): SchedulerEventModel[]|any[];
        mapAssignmentsForResource(resource: SchedulerResourceModel|number|string, fn?: Function, filterFn?: Function): SchedulerResourceModel[]|any[];
        removeAssignmentsForEvent(event: TimeSpan): void;
        removeAssignmentsForResource(resource: SchedulerResourceModel|any): void;
        unassignEventFromResource(event: TimeSpan|string|number, resources?: SchedulerResourceModel|string|number): SchedulerAssignmentModel|SchedulerAssignmentModel[];
    }

    type CrudManagerConfig = {
        assignmentStore: SchedulerAssignmentStore|object|Partial<SchedulerAssignmentStoreConfig>
        autoLoad: boolean
        autoSync: boolean
        autoSyncTimeout: number
        bubbleEvents: object
        crudStores: Store[]|string[]|object[]|Partial<StoreConfig>[]
        dependencyStore: SchedulerDependencyStore|object|Partial<SchedulerDependencyStoreConfig>
        encoder: object
        eventStore: SchedulerEventStore|object|Partial<SchedulerEventStoreConfig>
        listeners: object
        phantomIdField: string
        phantomParentIdField: string
        project: SchedulerProjectModel
        resetIdsBeforeSync: boolean
        resourceStore: SchedulerResourceStore|object|Partial<SchedulerResourceStoreConfig>
        skipSuccessProperty: boolean
        storeIdProperty: string
        stores: Store[]|string[]|object[]|Partial<StoreConfig>[]
        supportShortSyncResponse: boolean
        syncApplySequence: string[]
        trackResponseType: boolean
        transport: object
        validateResponse: boolean
        writeAllFields: boolean
        onBeforeDestroy: Function
        onBeforeLoad: Function
        onBeforeLoadApply: Function
        onBeforeResponseApply: Function
        onBeforeSend: Function
        onBeforeSync: Function
        onBeforeSyncApply: Function
        onCatchAll: Function
        onDestroy: Function
        onHasChanges: Function
        onLoad: Function
        onLoadCanceled: Function
        onLoadFail: Function
        onNoChanges: Function
        onRequestDone: Function
        onRequestFail: Function
        onSync: Function
        onSyncCanceled: Function
        onSyncDelayed: Function
        onSyncFail: Function
    }

    export class CrudManager extends AbstractCrudManager implements SchedulerProjectCrudManager, JsonEncoder, AjaxTransport {
        assignmentStore: SchedulerAssignmentStore
        changes: object
        crudRevision: number
        crudStores: object[]
        dependencyStore: SchedulerDependencyStore
        eventStore: SchedulerEventStore
        isCrudManagerLoading: boolean
        isCrudManagerSyncing: boolean
        resourceStore: SchedulerResourceStore
        resourceTimeRangeStore: Store
        syncApplySequence: object[]
        timeRangeStore: Store
        timeRangesStore: Store
        onBeforeDestroy: Function
        onBeforeLoad: Function
        onBeforeLoadApply: Function
        onBeforeResponseApply: Function
        onBeforeSend: Function
        onBeforeSync: Function
        onBeforeSyncApply: Function
        onCatchAll: Function
        onDestroy: Function
        onHasChanges: Function
        onLoad: Function
        onLoadCanceled: Function
        onLoadFail: Function
        onNoChanges: Function
        onRequestDone: Function
        onRequestFail: Function
        onSync: Function
        onSyncCanceled: Function
        onSyncDelayed: Function
        onSyncFail: Function
        constructor(config?: Partial<CrudManagerConfig>);
        acceptChanges(): void;
        addCrudStore(store: Store|string|object|Store[]|string[]|object[]|Partial<StoreConfig>|Partial<StoreConfig>[], position?: number, fromStore?: string|Store|object|Partial<StoreConfig>): void;
        addListener(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        addStoreToApplySequence(store: Store|object|Store[]|object[]|Partial<StoreConfig>|Partial<StoreConfig>[], position?: number, fromStore?: string|Store|object|Partial<StoreConfig>): void;
        cancelRequest(requestPromise: Promise<any>): void;
        commitCrudStores(): void;
        crudStoreHasChanges(storeId?: string|Store): boolean;
        decode(responseText: string): object;
        doDestroy(): void;
        encode(requestData: object): string;
        getCrudStore(storeId: string): Store;
        getStoreDescriptor(storeId: string|Store): object;
        hasListener(eventName: string): boolean;
        load(options?: object): Promise<any>;
        loadCrudManagerData(response: object, options?: object): void;
        on(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        rejectCrudStores(): void;
        relayAll(through: Events, prefix: string, transformCase?: boolean): void;
        removeAllListeners(): void;
        removeCrudStore(store: object|string|Store|Partial<StoreConfig>): void;
        removeListener(config: object, thisObj: object): void;
        removeStoreFromApplySequence(store: object|string|Store|Partial<StoreConfig>): void;
        resumeAutoSync(doSync?: boolean): void;
        resumeEvents(): void;
        revertChanges(): void;
        sendRequest(request: object): Promise<any>;
        suspendAutoSync(): void;
        suspendEvents(queue?: boolean): void;
        sync(): Promise<any>;
        trigger(eventName: string, param?: object): boolean|Promise<any>;
        un(config: object, thisObj?: object): void;
    }

    type SchedulerDependencyStoreConfig = {
        allowNoId: boolean
        autoCommit: boolean
        autoLoad: boolean
        autoTree: boolean
        bubbleEvents: object
        chainedFields: string[]
        chainedFilterFn: Function
        createUrl: string
        data: object[]|Model[]|Partial<ModelConfig>[]
        deleteUrl: string
        doRelayToMaster: string[]
        dontRelayToMaster: string
        fetchOptions: object
        fields: string[]|object[]|DataField[]|Partial<DataFieldConfig>[]
        filterParamName: string
        filters: object|object[]
        groupers: object[]
        headers: object
        httpMethods: object
        id: string|number
        keepUncommittedChanges: boolean
        listeners: object
        masterStore: Store
        modelClass: typeof Model
        pageParamName: string
        pageSize: number
        pageSizeParamName: string
        pageStartParamName: string
        params: object
        parentIdParamName: string
        readUrl: string
        reapplyFilterOnAdd: boolean
        reapplyFilterOnUpdate: boolean
        reapplySortersOnAdd: boolean
        responseDataProperty: string
        responseSuccessProperty: string
        responseTotalProperty: string
        restfulFilter: boolean
        sendAsFormData: boolean
        sortParamName: string
        sorters: object[]|string[]
        stm: StateTrackingManager
        storage: Collection|object|Partial<CollectionConfig>
        syncDataOnLoad: boolean|object
        transformFlatData: boolean
        tree: boolean
        updateUrl: string
        useLocaleSort: boolean|string|object
        useRawData: boolean|object
        useRestfulMethods: boolean
        writeAllFields: boolean
    }

    export class SchedulerDependencyStore extends AjaxStore implements SchedulerPartOfProject, DependencyStoreMixin {
        assignmentStore: SchedulerAssignmentStore
        data: object[]
        dependencyStore: SchedulerDependencyStore
        eventStore: SchedulerEventStore
        project: SchedulerProjectModel
        resourceStore: SchedulerResourceStore
        constructor(config?: Partial<SchedulerDependencyStoreConfig>);
        add(records: SchedulerDependencyModel|SchedulerDependencyModel[]|object|object[]|Partial<SchedulerDependencyModelConfig>|Partial<SchedulerDependencyModelConfig>[], silent?: boolean): SchedulerDependencyModel[];
        addAsync(records: SchedulerDependencyModel|SchedulerDependencyModel[]|object|object[]|Partial<SchedulerDependencyModelConfig>|Partial<SchedulerDependencyModelConfig>[], silent?: boolean): SchedulerDependencyModel[];
        getDependencyForSourceAndTargetEvents(sourceEvent: SchedulerEventModel|string, targetEvent: SchedulerEventModel|string): SchedulerDependencyModel;
        getEventDependencies(event: SchedulerEventModel): SchedulerDependencyModel[];
        getEventPredecessors(event: SchedulerEventModel): SchedulerDependencyModel[];
        getEventSuccessors(event: SchedulerEventModel): SchedulerDependencyModel[];
        getEventsLinkingDependency(sourceEvent: SchedulerEventModel|string, targetEvent: SchedulerEventModel|string): SchedulerDependencyModel;
        getHighlightedDependencies(cls: string): DependencyBaseModel[];
        isValidDependency(dependencyOrFromId: SchedulerDependencyModel|number|string, toId?: number|string, type?: number): boolean;
        isValidDependencyToCreate(fromId: number|string, toId: number|string, type: number): boolean;
        loadDataAsync(data: object[]): void;
    }

    type SchedulerEventStoreConfig = {
        allowNoId: boolean
        autoCommit: boolean
        autoLoad: boolean
        autoTree: boolean
        bubbleEvents: object
        chainedFields: string[]
        chainedFilterFn: Function
        createUrl: string
        data: object[]|Model[]|Partial<ModelConfig>[]
        deleteUrl: string
        doRelayToMaster: string[]
        dontRelayToMaster: string
        fetchOptions: object
        fields: string[]|object[]|DataField[]|Partial<DataFieldConfig>[]
        filterParamName: string
        filters: object|object[]
        groupers: object[]
        headers: object
        httpMethods: object
        id: string|number
        keepUncommittedChanges: boolean
        listeners: object
        masterStore: Store
        modelClass: SchedulerEventModel
        pageParamName: string
        pageSize: number
        pageSizeParamName: string
        pageStartParamName: string
        params: object
        parentIdParamName: string
        readUrl: string
        reapplyFilterOnAdd: boolean
        reapplyFilterOnUpdate: boolean
        reapplySortersOnAdd: boolean
        removeUnassignedEvent: boolean
        responseDataProperty: string
        responseSuccessProperty: string
        responseTotalProperty: string
        restfulFilter: boolean
        sendAsFormData: boolean
        sortParamName: string
        sorters: object[]|string[]
        stm: StateTrackingManager
        storage: Collection|object|Partial<CollectionConfig>
        syncDataOnLoad: boolean|object
        transformFlatData: boolean
        tree: boolean
        updateUrl: string
        useLocaleSort: boolean|string|object
        useRawData: boolean|object
        useRestfulMethods: boolean
        writeAllFields: boolean
        onLoadDateRange: Function
    }

    export class SchedulerEventStore extends AjaxStore implements SchedulerPartOfProject, SharedEventStoreMixin, EventStoreMixin, RecurringEventsMixin {
        assignmentStore: SchedulerAssignmentStore
        data: object[]
        dependencyStore: SchedulerDependencyStore
        eventStore: SchedulerEventStore
        modelClass: typeof EventModel
        project: SchedulerProjectModel
        resourceStore: SchedulerResourceStore
        onLoadDateRange: Function
        constructor(config?: Partial<SchedulerEventStoreConfig>);
        add(records: SchedulerEventModel|SchedulerEventModel[]|object|object[]|Partial<SchedulerEventModelConfig>|Partial<SchedulerEventModelConfig>[], silent?: boolean): SchedulerEventModel[];
        addAsync(records: SchedulerEventModel|SchedulerEventModel[]|object|object[]|Partial<SchedulerEventModelConfig>|Partial<SchedulerEventModelConfig>[], silent?: boolean): SchedulerEventModel[];
        append(record: SchedulerEventModel): void;
        assignEventToResource(event: SchedulerEventModel|string|number, resource: SchedulerResourceModel|string|number|SchedulerResourceModel[]|string[]|number[], removeExistingAssignments?: boolean): SchedulerAssignmentModel[];
        forEachScheduledEvent(fn: Function, thisObj: object): void;
        getAssignmentsForEvent(event: SchedulerEventModel|string|number): SchedulerAssignmentModel[];
        getAssignmentsForResource(resource: SchedulerResourceModel|string|number): SchedulerAssignmentModel[];
        getEvents(options: object): SchedulerEventModel[]|Map<any, any>;
        getEventsByStartDate(startDate: Date): SchedulerEventModel[];
        getEventsForResource(resource: SchedulerResourceModel|string|number): SchedulerEventModel[];
        getEventsInTimeSpan(startDate: Date, endDate: Date, allowPartial?: boolean, onlyAssigned?: boolean): SchedulerEventModel[];
        getRecurringEvents(): SchedulerEventModel[];
        getRecurringTimeSpans(): TimeSpan[];
        getResourcesForEvent(event: SchedulerEventModel|string|number): SchedulerResourceModel[];
        getTotalTimeSpan(): object;
        isDateRangeAvailable(start: Date, end: Date, excludeEvent: SchedulerEventModel|null, resource: SchedulerResourceModel): boolean;
        isEventAssignedToResource(event: SchedulerEventModel|string|number, resource: SchedulerResourceModel|string|number): boolean;
        isEventPersistable(event: SchedulerEventModel): boolean;
        loadDataAsync(data: object[]): void;
        reassignEventFromResourceToResource(event: SchedulerEventModel, oldResource: SchedulerResourceModel|SchedulerResourceModel[], newResource: SchedulerResourceModel|SchedulerResourceModel[]): void;
        removeAssignmentsForEvent(event: SchedulerEventModel|string|number): void;
        removeAssignmentsForResource(resource: SchedulerResourceModel|string|number): void;
        unassignEventFromResource(event: SchedulerEventModel|string|number, resource: SchedulerResourceModel|string|number): void;
    }

    type SchedulerResourceStoreConfig = {
        allowNoId: boolean
        autoCommit: boolean
        autoLoad: boolean
        autoTree: boolean
        bubbleEvents: object
        chainedFields: string[]
        chainedFilterFn: Function
        createUrl: string
        data: object[]|Model[]|Partial<ModelConfig>[]
        deleteUrl: string
        doRelayToMaster: string[]
        dontRelayToMaster: string
        fetchOptions: object
        fields: string[]|object[]|DataField[]|Partial<DataFieldConfig>[]
        filterParamName: string
        filters: object|object[]
        groupers: object[]
        headers: object
        httpMethods: object
        id: string|number
        keepUncommittedChanges: boolean
        listeners: object
        masterStore: Store
        modelClass: typeof Model
        pageParamName: string
        pageSize: number
        pageSizeParamName: string
        pageStartParamName: string
        params: object
        parentIdParamName: string
        readUrl: string
        reapplyFilterOnAdd: boolean
        reapplyFilterOnUpdate: boolean
        reapplySortersOnAdd: boolean
        responseDataProperty: string
        responseSuccessProperty: string
        responseTotalProperty: string
        restfulFilter: boolean
        sendAsFormData: boolean
        sortParamName: string
        sorters: object[]|string[]
        stm: StateTrackingManager
        storage: Collection|object|Partial<CollectionConfig>
        syncDataOnLoad: boolean|object
        transformFlatData: boolean
        tree: boolean
        updateUrl: string
        useLocaleSort: boolean|string|object
        useRawData: boolean|object
        useRestfulMethods: boolean
        writeAllFields: boolean
    }

    export class SchedulerResourceStore extends AjaxStore implements SchedulerPartOfProject, ResourceStoreMixin {
        assignmentStore: SchedulerAssignmentStore
        data: object[]
        dependencyStore: SchedulerDependencyStore
        eventStore: SchedulerEventStore
        project: SchedulerProjectModel
        resourceStore: SchedulerResourceStore
        constructor(config?: Partial<SchedulerResourceStoreConfig>);
        add(records: SchedulerResourceModel|SchedulerResourceModel[]|object|object[]|Partial<SchedulerResourceModelConfig>|Partial<SchedulerResourceModelConfig>[], silent?: boolean): SchedulerResourceModel[];
        addAsync(records: SchedulerResourceModel|SchedulerResourceModel[]|object|object[]|Partial<SchedulerResourceModelConfig>|Partial<SchedulerResourceModelConfig>[], silent?: boolean): SchedulerResourceModel[];
        loadDataAsync(data: object[]): void;
    }

    type ResourceTimeRangeStoreConfig = {
        allowNoId: boolean
        autoCommit: boolean
        autoLoad: boolean
        autoTree: boolean
        bubbleEvents: object
        chainedFields: string[]
        chainedFilterFn: Function
        createUrl: string
        data: object[]|Model[]|Partial<ModelConfig>[]
        deleteUrl: string
        doRelayToMaster: string[]
        dontRelayToMaster: string
        fetchOptions: object
        fields: string[]|object[]|DataField[]|Partial<DataFieldConfig>[]
        filterParamName: string
        filters: object|object[]
        groupers: object[]
        headers: object
        httpMethods: object
        id: string|number
        keepUncommittedChanges: boolean
        listeners: object
        masterStore: Store
        modelClass: typeof Model
        pageParamName: string
        pageSize: number
        pageSizeParamName: string
        pageStartParamName: string
        params: object
        parentIdParamName: string
        readUrl: string
        reapplyFilterOnAdd: boolean
        reapplyFilterOnUpdate: boolean
        reapplySortersOnAdd: boolean
        resourceStore: SchedulerResourceStore
        responseDataProperty: string
        responseSuccessProperty: string
        responseTotalProperty: string
        restfulFilter: boolean
        sendAsFormData: boolean
        sortParamName: string
        sorters: object[]|string[]
        stm: StateTrackingManager
        storage: Collection|object|Partial<CollectionConfig>
        syncDataOnLoad: boolean|object
        transformFlatData: boolean
        tree: boolean
        updateUrl: string
        useLocaleSort: boolean|string|object
        useRawData: boolean|object
        useRestfulMethods: boolean
        writeAllFields: boolean
    }

    export class ResourceTimeRangeStore extends AjaxStore {
        constructor(config?: Partial<ResourceTimeRangeStoreConfig>);
    }

    type TimeAxisConfig = {
        allowNoId: boolean
        autoAdjust: boolean
        autoCommit: boolean
        autoTree: boolean
        bubbleEvents: object
        chainedFields: string[]
        chainedFilterFn: Function
        continuous: boolean
        data: object[]|Model[]|Partial<ModelConfig>[]
        doRelayToMaster: string[]
        dontRelayToMaster: string
        fields: string[]|object[]|DataField[]|Partial<DataFieldConfig>[]
        filters: object|object[]
        groupers: object[]
        id: string|number
        include: object
        keepUncommittedChanges: boolean
        listeners: object
        masterStore: Store
        modelClass: typeof Model
        reapplyFilterOnAdd: boolean
        reapplyFilterOnUpdate: boolean
        reapplySortersOnAdd: boolean
        sorters: object[]|string[]
        stm: StateTrackingManager
        storage: Collection|object|Partial<CollectionConfig>
        syncDataOnLoad: boolean|object
        transformFlatData: boolean
        tree: boolean
        useLocaleSort: boolean|string|object
        useRawData: boolean|object
        onBeforereconfigure: Function
        onInvalidFilter: Function
        onReconfigure: Function
    }

    export class TimeAxis extends Store {
        endDate: Date
        isContinuous: boolean
        startDate: Date
        ticks: object[]
        viewPreset: ViewPreset
        onBeforereconfigure: Function
        onInvalidFilter: Function
        onReconfigure: Function
        constructor(config?: Partial<TimeAxisConfig>);
        dateInAxis(date: Date): boolean;
        filterBy(fn: Function, thisObj?: object): void;
        generateTicks(axisStartDate: Date, axisEndDate: Date, unit: string, increment: number): any[];
        getDateFromTick(tick: number, roundingMethod?: string): Date;
        getTickFromDate(date: Date): number;
        setTimeSpan(newStartDate: Date, newEndDate: Date): void;
        shift(amount: number, unit?: string): void;
        shiftNext(amount?: number): void;
        shiftPrevious(amount?: number): void;
        timeSpanInAxis(start: Date, end: Date): boolean;
    }

    export class AssignmentStoreMixin {
        data: object[]
        add(records: SchedulerAssignmentModel|SchedulerAssignmentModel[]|object|object[]|Partial<SchedulerAssignmentModelConfig>|Partial<SchedulerAssignmentModelConfig>[], silent?: boolean): SchedulerAssignmentModel[];
        addAsync(records: SchedulerAssignmentModel|SchedulerAssignmentModel[]|object|object[]|Partial<SchedulerAssignmentModelConfig>|Partial<SchedulerAssignmentModelConfig>[], silent?: boolean): SchedulerAssignmentModel[];
        assignEventToResource(event: TimeSpan, resources: SchedulerResourceModel|SchedulerResourceModel[], assignmentSetupFn?: Function, removeExistingAssignments?: boolean): SchedulerAssignmentModel[];
        getAssignmentForEventAndResource(event: SchedulerEventModel|string|number, resource: SchedulerResourceModel|string|number): SchedulerAssignmentModel;
        getAssignmentsForEvent(event: TimeSpan): SchedulerAssignmentModel[];
        getAssignmentsForResource(resource: SchedulerResourceModel): SchedulerAssignmentModel[];
        getEventsForResource(resource: SchedulerResourceModel|string|number): TimeSpan[];
        getResourcesForEvent(event: SchedulerEventModel): SchedulerResourceModel[];
        isEventAssignedToResource(event: SchedulerEventModel|string|number, resource: SchedulerResourceModel|string|number): boolean;
        loadDataAsync(data: object[]): void;
        mapAssignmentsForEvent(event: SchedulerEventModel, fn?: Function, filterFn?: Function): SchedulerEventModel[]|any[];
        mapAssignmentsForResource(resource: SchedulerResourceModel|number|string, fn?: Function, filterFn?: Function): SchedulerResourceModel[]|any[];
        removeAssignmentsForEvent(event: TimeSpan): void;
        removeAssignmentsForResource(resource: SchedulerResourceModel|any): void;
        unassignEventFromResource(event: TimeSpan|string|number, resources?: SchedulerResourceModel|string|number): SchedulerAssignmentModel|SchedulerAssignmentModel[];
    }

    export class AttachToProjectMixin {
        attachToAssignmentStore(store: SchedulerAssignmentStore): void;
        attachToCalendarManagerStore(store: Store): void;
        attachToDependencyStore(store: SchedulerDependencyStore): void;
        attachToEventStore(store: SchedulerEventStore): void;
        attachToProject(project: SchedulerProjectModel): void;
        attachToResourceStore(store: SchedulerResourceStore): void;
    }

    export class DependencyStoreMixin {
        data: object[]
        add(records: SchedulerDependencyModel|SchedulerDependencyModel[]|object|object[]|Partial<SchedulerDependencyModelConfig>|Partial<SchedulerDependencyModelConfig>[], silent?: boolean): SchedulerDependencyModel[];
        addAsync(records: SchedulerDependencyModel|SchedulerDependencyModel[]|object|object[]|Partial<SchedulerDependencyModelConfig>|Partial<SchedulerDependencyModelConfig>[], silent?: boolean): SchedulerDependencyModel[];
        getDependencyForSourceAndTargetEvents(sourceEvent: SchedulerEventModel|string, targetEvent: SchedulerEventModel|string): SchedulerDependencyModel;
        getEventDependencies(event: SchedulerEventModel): SchedulerDependencyModel[];
        getEventPredecessors(event: SchedulerEventModel): SchedulerDependencyModel[];
        getEventSuccessors(event: SchedulerEventModel): SchedulerDependencyModel[];
        getEventsLinkingDependency(sourceEvent: SchedulerEventModel|string, targetEvent: SchedulerEventModel|string): SchedulerDependencyModel;
        getHighlightedDependencies(cls: string): DependencyBaseModel[];
        isValidDependency(dependencyOrFromId: SchedulerDependencyModel|number|string, toId?: number|string, type?: number): boolean;
        isValidDependencyToCreate(fromId: number|string, toId: number|string, type: number): boolean;
        loadDataAsync(data: object[]): void;
    }

    type EventStoreMixinConfig = {
        onLoadDateRange: Function
    }

    export class EventStoreMixin {
        onLoadDateRange: Function
        assignEventToResource(event: SchedulerEventModel|string|number, resource: SchedulerResourceModel|string|number|SchedulerResourceModel[]|string[]|number[], removeExistingAssignments?: boolean): SchedulerAssignmentModel[];
        forEachScheduledEvent(fn: Function, thisObj: object): void;
        getAssignmentsForEvent(event: SchedulerEventModel|string|number): SchedulerAssignmentModel[];
        getAssignmentsForResource(resource: SchedulerResourceModel|string|number): SchedulerAssignmentModel[];
        getEvents(options: object): SchedulerEventModel[]|Map<any, any>;
        getEventsByStartDate(startDate: Date): SchedulerEventModel[];
        getEventsForResource(resource: SchedulerResourceModel|string|number): SchedulerEventModel[];
        getEventsInTimeSpan(startDate: Date, endDate: Date, allowPartial?: boolean, onlyAssigned?: boolean): SchedulerEventModel[];
        getResourcesForEvent(event: SchedulerEventModel|string|number): SchedulerResourceModel[];
        getTotalTimeSpan(): object;
        isDateRangeAvailable(start: Date, end: Date, excludeEvent: SchedulerEventModel|null, resource: SchedulerResourceModel): boolean;
        isEventAssignedToResource(event: SchedulerEventModel|string|number, resource: SchedulerResourceModel|string|number): boolean;
        isEventPersistable(event: SchedulerEventModel): boolean;
        reassignEventFromResourceToResource(event: SchedulerEventModel, oldResource: SchedulerResourceModel|SchedulerResourceModel[], newResource: SchedulerResourceModel|SchedulerResourceModel[]): void;
        removeAssignmentsForEvent(event: SchedulerEventModel|string|number): void;
        removeAssignmentsForResource(resource: SchedulerResourceModel|string|number): void;
        unassignEventFromResource(event: SchedulerEventModel|string|number, resource: SchedulerResourceModel|string|number): void;
    }

    export class SchedulerPartOfProject {
        assignmentStore: SchedulerAssignmentStore
        dependencyStore: SchedulerDependencyStore
        eventStore: SchedulerEventStore
        project: SchedulerProjectModel
        resourceStore: SchedulerResourceStore
    }

    type ProjectConsumerConfig = {
        destroyStores: boolean
        project: SchedulerProjectModel|object|Partial<SchedulerProjectModelConfig>
        onDataChange: Function
    }

    export class ProjectConsumer {
        isEngineReady: boolean
        project: SchedulerProjectModel
        onDataChange: Function
        constructor(config?: Partial<ProjectConsumerConfig>);
        updateProject(project: SchedulerProjectModel): void;
        whenProjectReady(callback: Function): void;
    }

    type SchedulerProjectCrudManagerConfig = {
        autoLoad: boolean
        autoSync: boolean
        autoSyncTimeout: number
        bubbleEvents: object
        crudStores: Store[]|string[]|object[]|Partial<StoreConfig>[]
        encoder: object
        listeners: object
        phantomIdField: string
        phantomParentIdField: string
        project: SchedulerProjectModel
        resetIdsBeforeSync: boolean
        skipSuccessProperty: boolean
        storeIdProperty: string
        supportShortSyncResponse: boolean
        syncApplySequence: string[]
        trackResponseType: boolean
        transport: object
        validateResponse: boolean
        writeAllFields: boolean
        onBeforeDestroy: Function
        onBeforeLoad: Function
        onBeforeLoadApply: Function
        onBeforeResponseApply: Function
        onBeforeSend: Function
        onBeforeSync: Function
        onBeforeSyncApply: Function
        onCatchAll: Function
        onDestroy: Function
        onHasChanges: Function
        onLoad: Function
        onLoadCanceled: Function
        onLoadFail: Function
        onNoChanges: Function
        onRequestDone: Function
        onRequestFail: Function
        onSync: Function
        onSyncCanceled: Function
        onSyncDelayed: Function
        onSyncFail: Function
    }

    export class SchedulerProjectCrudManager implements AbstractCrudManagerMixin, AjaxTransport, JsonEncoder {
        changes: object
        crudRevision: number
        crudStores: object[]
        isCrudManagerLoading: boolean
        isCrudManagerSyncing: boolean
        syncApplySequence: object[]
        onBeforeDestroy: Function
        onBeforeLoad: Function
        onBeforeLoadApply: Function
        onBeforeResponseApply: Function
        onBeforeSend: Function
        onBeforeSync: Function
        onBeforeSyncApply: Function
        onCatchAll: Function
        onDestroy: Function
        onHasChanges: Function
        onLoad: Function
        onLoadCanceled: Function
        onLoadFail: Function
        onNoChanges: Function
        onRequestDone: Function
        onRequestFail: Function
        onSync: Function
        onSyncCanceled: Function
        onSyncDelayed: Function
        onSyncFail: Function
        constructor(config?: Partial<SchedulerProjectCrudManagerConfig>);
        acceptChanges(): void;
        addCrudStore(store: Store|string|object|Store[]|string[]|object[]|Partial<StoreConfig>|Partial<StoreConfig>[], position?: number, fromStore?: string|Store|object|Partial<StoreConfig>): void;
        addListener(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        addStoreToApplySequence(store: Store|object|Store[]|object[]|Partial<StoreConfig>|Partial<StoreConfig>[], position?: number, fromStore?: string|Store|object|Partial<StoreConfig>): void;
        cancelRequest(requestPromise: Promise<any>): void;
        commitCrudStores(): void;
        crudStoreHasChanges(storeId?: string|Store): boolean;
        decode(responseText: string): object;
        doDestroy(): void;
        encode(requestData: object): string;
        getCrudStore(storeId: string): Store;
        getStoreDescriptor(storeId: string|Store): object;
        hasListener(eventName: string): boolean;
        load(options?: object): Promise<any>;
        loadCrudManagerData(response: object, options?: object): void;
        on(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        rejectCrudStores(): void;
        relayAll(through: Events, prefix: string, transformCase?: boolean): void;
        removeAllListeners(): void;
        removeCrudStore(store: object|string|Store|Partial<StoreConfig>): void;
        removeListener(config: object, thisObj: object): void;
        removeStoreFromApplySequence(store: object|string|Store|Partial<StoreConfig>): void;
        resumeAutoSync(doSync?: boolean): void;
        resumeEvents(): void;
        revertChanges(): void;
        sendRequest(request: object): Promise<any>;
        suspendAutoSync(): void;
        suspendEvents(queue?: boolean): void;
        sync(): Promise<any>;
        trigger(eventName: string, param?: object): boolean|Promise<any>;
        un(config: object, thisObj?: object): void;
    }

    export class RecurringEventsMixin extends RecurringTimeSpansMixin {
        getRecurringEvents(): SchedulerEventModel[];
    }

    export class RecurringTimeSpansMixin {
        getRecurringTimeSpans(): TimeSpan[];
    }

    export class ResourceStoreMixin {
        data: object[]
        add(records: SchedulerResourceModel|SchedulerResourceModel[]|object|object[]|Partial<SchedulerResourceModelConfig>|Partial<SchedulerResourceModelConfig>[], silent?: boolean): SchedulerResourceModel[];
        addAsync(records: SchedulerResourceModel|SchedulerResourceModel[]|object|object[]|Partial<SchedulerResourceModelConfig>|Partial<SchedulerResourceModelConfig>[], silent?: boolean): SchedulerResourceModel[];
        loadDataAsync(data: object[]): void;
    }

    type SharedEventStoreMixinConfig = {
        removeUnassignedEvent: boolean
    }

    export class SharedEventStoreMixin {
        data: object[]
        modelClass: typeof EventModel
        constructor(config?: Partial<SharedEventStoreMixinConfig>);
        add(records: SchedulerEventModel|SchedulerEventModel[]|object|object[]|Partial<SchedulerEventModelConfig>|Partial<SchedulerEventModelConfig>[], silent?: boolean): SchedulerEventModel[];
        addAsync(records: SchedulerEventModel|SchedulerEventModel[]|object|object[]|Partial<SchedulerEventModelConfig>|Partial<SchedulerEventModelConfig>[], silent?: boolean): SchedulerEventModel[];
        append(record: SchedulerEventModel): void;
        loadDataAsync(data: object[]): void;
    }

    type AbstractTimeRangesConfig = {
        bubbleEvents: object
        disabled: boolean
        enableResizing: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        showHeaderElements: boolean
        showTooltip: boolean|object
        store: object|Store|Partial<StoreConfig>
        tooltipTemplate: Function
    }

    export abstract class AbstractTimeRanges extends InstancePlugin implements Delayable {
        showHeaderElements: boolean
        store: Store
        timeRanges: TimeSpan[]
        constructor(config?: Partial<AbstractTimeRangesConfig>);
        getTipHtml(): void;
        shouldRenderRange(range: TimeSpan): boolean;
    }

    type ColumnLinesConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
    }

    export class ColumnLines extends InstancePlugin implements Delayable {
        constructor(config?: Partial<ColumnLinesConfig>);
    }

    type SchedulerDependenciesConfig = {
        allowCreate: boolean
        allowDropOnEventBar: boolean
        bubbleEvents: object
        creationTooltip: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        pathFinderConfig: object
        showCreationTooltip: boolean
        showTooltip: boolean
        terminalCls: string
        terminalSides: string[]
        tooltip: object
        onAfterDependencyCreateDrop: Function
        onBeforeDependencyCreateDrag: Function
        onBeforeDependencyCreateFinalize: Function
        onDependenciesDrawn: Function
        onDependencyClick: Function
        onDependencyCreateDragStart: Function
        onDependencyCreateDrop: Function
        onDependencyDblClick: Function
        onDependencyMouseOut: Function
        onDependencyMouseOver: Function
        onDependencyValidationComplete: Function
        onDependencyValidationStart: Function
    }

    export class SchedulerDependencies extends InstancePlugin implements Delayable, DependencyCreation {
        allowDropOnEventBar: boolean
        onAfterDependencyCreateDrop: Function
        onBeforeDependencyCreateDrag: Function
        onBeforeDependencyCreateFinalize: Function
        onDependenciesDrawn: Function
        onDependencyClick: Function
        onDependencyCreateDragStart: Function
        onDependencyCreateDrop: Function
        onDependencyDblClick: Function
        onDependencyMouseOut: Function
        onDependencyMouseOver: Function
        onDependencyValidationComplete: Function
        onDependencyValidationStart: Function
        constructor(config?: Partial<SchedulerDependenciesConfig>);
        abort(): void;
        draw(): void;
        drawDependency(dependency: SchedulerDependencyModel): void;
        drawForEvent(): void;
        getConnectorEndSide(timeSpanRecord: TimeSpan): string;
        getConnectorStartSide(timeSpanRecord: TimeSpan): string;
        hideTerminals(eventElement: HTMLElement): void;
        refreshDependency(dependency: SchedulerDependencyModel): void;
        releaseDependency(dependency: SchedulerDependencyModel): void;
        resolveDependencyRecord(element: HTMLElement): SchedulerDependencyModel;
        showTerminals(timeSpanRecord: TimeSpan, element: HTMLElement): void;
    }

    type SchedulerDependencyEditConfig = {
        autoClose: boolean
        bubbleEvents: object
        disabled: boolean
        editorConfig: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        saveAndCloseOnEnter: boolean
        showDeleteButton: boolean
        showLagField: boolean
        triggerEvent: string
        onAfterDependencySave: Function
        onBeforeDependencyAdd: Function
        onBeforeDependencyDelete: Function
        onBeforeDependencyEdit: Function
        onBeforeDependencyEditShow: Function
        onBeforeDependencySave: Function
    }

    export class SchedulerDependencyEdit extends InstancePlugin {
        cancelButton: Button
        deleteButton: Button
        fromNameField: DisplayField
        lagField: DurationField
        saveButton: Button
        toNameField: DisplayField
        typeField: Combo
        onAfterDependencySave: Function
        onBeforeDependencyAdd: Function
        onBeforeDependencyDelete: Function
        onBeforeDependencyEdit: Function
        onBeforeDependencyEditShow: Function
        onBeforeDependencySave: Function
        constructor(config?: Partial<SchedulerDependencyEditConfig>);
        editDependency(dependencyRecord: SchedulerDependencyModel): void;
        onAfterSave(dependencyRecord: SchedulerDependencyModel): void;
        onBeforeSave(dependencyRecord: SchedulerDependencyModel): void;
    }

    type EventContextMenuConfig = {
        bubbleEvents: object
        disabled: boolean
        items: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        menu: object
        menuConfig: object
        processItems: Function
        triggerEvent: string
        type: string
    }

    export class EventContextMenu extends EventMenu {
        constructor(config?: Partial<EventContextMenuConfig>);
    }

    type EventCopyPasteConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
    }

    export class EventCopyPaste extends InstancePlugin {
        constructor(config?: Partial<EventCopyPasteConfig>);
        copyEvents(records?: any[], isCut?: boolean): void;
        pasteEvents(date?: Date, resourceRecord?: object): void;
    }

    type EventDragConfig = {
        bubbleEvents: object
        constrainDragToResource: boolean
        constrainDragToTimeSlot: boolean
        constrainDragToTimeline: boolean
        disabled: boolean
        dragHelperConfig: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        showExactDropPosition: boolean
        showTooltip: boolean
        tooltipTemplate: Function
        unifiedDrag: boolean
        validatorFn: Function
        validatorFnThisObj: object
        onAfterEventDrop: Function
        onBeforeEventDrag: Function
        onBeforeEventDropFinalize: Function
        onEventDrag: Function
        onEventDragAbort: Function
        onEventDragStart: Function
        onEventDrop: Function
    }

    export class EventDrag extends DragBase {
        constrainDragToResource: boolean
        constrainDragToTimeSlot: boolean
        unifiedDrag: boolean
        onAfterEventDrop: Function
        onBeforeEventDrag: Function
        onBeforeEventDropFinalize: Function
        onEventDrag: Function
        onEventDragAbort: Function
        onEventDragStart: Function
        onEventDrop: Function
        constructor(config?: Partial<EventDragConfig>);
        getRelatedRecords(assignmentRecord: SchedulerAssignmentModel): SchedulerAssignmentModel[];
    }

    type EventDragCreateConfig = {
        bubbleEvents: object
        disabled: boolean
        dragTolerance: number
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        lockLayout: boolean
        showTooltip: boolean
        validatorFn: Function
        validatorFnThisObj: object
        onAfterDragCreate: Function
        onBeforeDragCreate: Function
        onBeforeDragCreateFinalize: Function
        onDragCreateEnd: Function
        onDragCreateStart: Function
    }

    export class EventDragCreate extends DragCreateBase {
        onAfterDragCreate: Function
        onBeforeDragCreate: Function
        onBeforeDragCreateFinalize: Function
        onDragCreateEnd: Function
        onDragCreateStart: Function
        constructor(config?: Partial<EventDragCreateConfig>);
    }

    type EventDragSelectConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
    }

    export class EventDragSelect extends InstancePlugin implements Delayable {
        constructor(config?: Partial<EventDragSelectConfig>);
    }

    type EventEditConfig = {
        autoClose: boolean
        bubbleEvents: object
        dateFormat: string
        disabled: boolean
        editorConfig: object
        endDateConfig: object
        endTimeConfig: object
        extraItems: string|object[]
        items: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        readOnly: boolean
        resourceFieldConfig: object
        saveAndCloseOnEnter: boolean
        showDeleteButton: boolean
        showNameField: boolean
        showRecurringUI: boolean
        showResourceField: boolean
        startDateConfig: object
        startTimeConfig: object
        timeFormat: string
        triggerEvent: string
        typeField: string
        weekStartDay: number
        onAfterEventSave: Function
        onBeforeEventEdit: Function
        onBeforeEventEditShow: Function
        onBeforeEventSave: Function
        onEventEditBeforeSetRecord: Function
    }

    export class EventEdit extends EditBase implements RecurringEventEdit {
        cancelButton: Button
        deleteButton: Button
        editRecurrenceButton: RecurrenceLegendButton
        endDateField: DateField
        endTimeField: TimeField
        eventRecord: SchedulerEventModel
        isEditing: boolean
        nameField: TextField
        readOnly: boolean
        recurrenceCombo: RecurrenceCombo
        resourceField: Combo
        saveButton: Button
        startDateField: DateField
        startTimeField: TimeField
        onAfterEventSave: Function
        onBeforeEventEdit: Function
        onBeforeEventEditShow: Function
        onBeforeEventSave: Function
        onEventEditBeforeSetRecord: Function
        constructor(config?: Partial<EventEditConfig>);
        editEvent(eventRecord: SchedulerEventModel, resourceRecord?: SchedulerResourceModel, element?: HTMLElement): void;
    }

    type EventFilterConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
    }

    export class EventFilter extends InstancePlugin {
        constructor(config?: Partial<EventFilterConfig>);
    }

    type EventMenuConfig = {
        bubbleEvents: object
        disabled: boolean
        items: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        menu: object
        menuConfig: object
        processItems: Function
        triggerEvent: string
        type: string
        onEventMenuBeforeShow: Function
        onEventMenuItem: Function
        onEventMenuShow: Function
    }

    export class EventMenu extends TimeSpanMenuBase {
        onEventMenuBeforeShow: Function
        onEventMenuItem: Function
        onEventMenuShow: Function
        constructor(config?: Partial<EventMenuConfig>);
        showContextMenuFor(eventRecord: SchedulerEventModel|TaskModel, options?: object): void;
    }

    type SchedulerEventResizeConfig = {
        allowResizeToZero: boolean
        bottomHandle: boolean
        bubbleEvents: object
        disabled: boolean
        dragThreshold: number
        dynamicHandleSize: boolean
        handleSize: number
        leftHandle: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        reservedSpace: number
        rightHandle: boolean
        showExactResizePosition: boolean
        tip: Tooltip|object|Partial<TooltipConfig>
        tooltipTemplate: Function
        topHandle: boolean
        touchHandleSize: number
        validatorFn: Function
        validatorFnThisObj: object
        onBeforeEventResize: Function
        onBeforeEventResizeFinalize: Function
        onEventPartialResize: Function
        onEventResizeEnd: Function
        onEventResizeStart: Function
    }

    export class SchedulerEventResize extends InstancePlugin {
        tip: Tooltip|object|Partial<TooltipConfig>
        onBeforeEventResize: Function
        onBeforeEventResizeFinalize: Function
        onEventPartialResize: Function
        onEventResizeEnd: Function
        onEventResizeStart: Function
        constructor(config?: Partial<SchedulerEventResizeConfig>);
    }

    type EventTooltipConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        allowOver: boolean
        anchor: boolean
        anchorToTarget: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoShow: boolean
        autoUpdate: boolean
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dismissDelay: number
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        forSelector: string
        getHtml: Function
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideDelay: number
        hideOnDelegateChange: boolean
        hideWhenEmpty: boolean
        hoverDelay: number
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        loadingMsg: string
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maximizable: boolean
        maximized: boolean
        minHeight: string|number
        minWidth: string|number
        modal: boolean
        monitorResize: boolean
        mouseOffsetX: number
        mouseOffsetY: number
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showOnClick: boolean
        showOnHover: boolean
        strips: object
        style: string
        tab: boolean|object
        tag: string
        tbar: object[]|object
        template: Function
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        trapFocus: boolean
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class EventTooltip extends TooltipBase {
        constructor(config?: Partial<EventTooltipConfig>);
    }

    type GroupSummaryConfig = {
        bubbleEvents: object
        collapseToHeader: boolean
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        renderer: Function
        showTooltip: boolean
        summaries: object[]
    }

    export class GroupSummary extends GridGroupSummary {
        constructor(config?: Partial<GroupSummaryConfig>);
    }

    type HeaderContextMenuConfig = {
        bubbleEvents: object
        disabled: boolean
        extraItems: object[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        processItems: Function
    }

    export class HeaderContextMenu extends InstancePlugin {
        constructor(config?: Partial<HeaderContextMenuConfig>);
    }

    type HeaderZoomConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
    }

    export class HeaderZoom extends InstancePlugin {
        constructor(config?: Partial<HeaderZoomConfig>);
    }

    type SchedulerLabelsConfig = {
        blurAction: string
        bottom: object
        bubbleEvents: object
        disabled: boolean
        labelCharWidth: number
        labelCls: string
        labelLayoutMode: string
        left: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        right: object
        top: object
    }

    export class SchedulerLabels extends InstancePlugin {
        constructor(config?: Partial<SchedulerLabelsConfig>);
    }

    type NonWorkingTimeConfig = {
        bubbleEvents: object
        disabled: boolean
        enableResizing: boolean
        hideRangesOnZooming: boolean
        highlightWeekends: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        maxTimeAxisUnit: string
        showHeaderElements: boolean
        showTooltip: boolean|object
        store: object|Store|Partial<StoreConfig>
        tooltipTemplate: Function
    }

    export class NonWorkingTime extends AbstractTimeRanges {
        constructor(config?: Partial<NonWorkingTimeConfig>);
        shouldRenderRange(range: TimeSpan): boolean;
    }

    type PanConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        vertical: boolean
    }

    export class Pan extends InstancePlugin {
        constructor(config?: Partial<PanConfig>);
    }

    type ResourceTimeRangesConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        resourceTimeRanges: ResourceTimeRangeModel[]|object[]|Partial<ResourceTimeRangeModelConfig>[]
        store: ResourceTimeRangeStore
    }

    export class ResourceTimeRanges extends ResourceTimeRangesBase {
        constructor(config?: Partial<ResourceTimeRangesConfig>);
    }

    type ScheduleContextConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
    }

    export class ScheduleContext extends InstancePlugin {
        constructor(config?: Partial<ScheduleContextConfig>);
    }

    type ScheduleContextMenuConfig = {
        bubbleEvents: object
        disabled: boolean
        items: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        menu: object
        menuConfig: object
        processItems: Function
        triggerEvent: string
        type: string
    }

    export class ScheduleContextMenu extends ScheduleMenu {
        constructor(config?: Partial<ScheduleContextMenuConfig>);
    }

    type ScheduleMenuConfig = {
        bubbleEvents: object
        disabled: boolean
        items: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        menu: object
        menuConfig: object
        processItems: Function
        triggerEvent: string
        type: string
        onScheduleMenuBeforeShow: Function
        onScheduleMenuItem: Function
        onScheduleMenuShow: Function
    }

    export class ScheduleMenu extends TimeSpanMenuBase {
        onScheduleMenuBeforeShow: Function
        onScheduleMenuItem: Function
        onScheduleMenuShow: Function
        constructor(config?: Partial<ScheduleMenuConfig>);
    }

    type ScheduleTooltipConfig = {
        bubbleEvents: object
        disabled: boolean
        hideForNonWorkingTime: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
    }

    export class ScheduleTooltip extends InstancePlugin {
        constructor(config?: Partial<ScheduleTooltipConfig>);
        generateTipContent(context: object): string;
        getText(date: Date, event: Event, resourceRecord: SchedulerResourceModel): string;
    }

    type SimpleEventEditConfig = {
        bubbleEvents: object
        disabled: boolean
        editorConfig: object
        field: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        triggerEvent: string
        onBeforeCancel: Function
        onBeforeComplete: Function
        onBeforeStart: Function
        onCancel: Function
        onComplete: Function
        onStart: Function
    }

    export class SimpleEventEdit extends InstancePlugin {
        eventRecord: SchedulerEventModel
        onBeforeCancel: Function
        onBeforeComplete: Function
        onBeforeStart: Function
        onCancel: Function
        onComplete: Function
        onStart: Function
        constructor(config?: Partial<SimpleEventEditConfig>);
        editEvent(eventRecord: SchedulerEventModel, resourceRecord?: SchedulerResourceModel): void;
    }

    type StickyEventsConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
    }

    export class StickyEvents extends InstancePlugin {
        constructor(config?: Partial<StickyEventsConfig>);
    }

    type SummaryConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        renderer: Function
        selectedOnly: boolean
        showTooltip: boolean
        summaries: object[]
        verticalSummaryColumnConfig: object
    }

    export class Summary extends GridSummary {
        constructor(config?: Partial<SummaryConfig>);
        refresh(): void;
    }

    type TimeAxisHeaderMenuConfig = {
        bubbleEvents: object
        disabled: boolean
        items: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        menu: object
        menuConfig: object
        processItems: Function
        triggerEvent: string
        type: string
        onTimeAxisHeaderContextMenuBeforeShow: Function
        onTimeAxisHeaderContextMenuItem: Function
        onTimeAxisHeaderContextMenuShow: Function
    }

    export class TimeAxisHeaderMenu extends HeaderMenu {
        onTimeAxisHeaderContextMenuBeforeShow: Function
        onTimeAxisHeaderContextMenuItem: Function
        onTimeAxisHeaderContextMenuShow: Function
        constructor(config?: Partial<TimeAxisHeaderMenuConfig>);
    }

    type TimeRangesConfig = {
        bubbleEvents: object
        currentDateFormat: string
        currentTimeLineUpdateInterval: number
        disabled: boolean
        enableResizing: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        showCurrentTimeLine: boolean|object
        showHeaderElements: boolean
        showTooltip: boolean|object
        store: object|Store|Partial<StoreConfig>
        timeRanges: TimeSpan[]|object[]|Partial<TimeSpanConfig>[]
        tooltipTemplate: Function
    }

    export class TimeRanges extends AbstractTimeRanges {
        disabled: boolean
        showCurrentTimeLine: boolean
        store: Store
        timeRanges: TimeSpan[]
        constructor(config?: Partial<TimeRangesConfig>);
        populateHeaderMenu(options: object): void;
    }

    type DragBaseConfig = {
        bubbleEvents: object
        constrainDragToTimeline: boolean
        disabled: boolean
        dragHelperConfig: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        showExactDropPosition: boolean
        showTooltip: boolean
    }

    export abstract class DragBase extends InstancePlugin {
        constructor(config?: Partial<DragBaseConfig>);
        getTipHtml(): void;
    }

    type DragCreateBaseConfig = {
        bubbleEvents: object
        disabled: boolean
        dragTolerance: number
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        showTooltip: boolean
        validatorFnThisObj: object
    }

    export class DragCreateBase extends InstancePlugin {
        constructor(config?: Partial<DragCreateBaseConfig>);
    }

    type EditBaseConfig = {
        autoClose: boolean
        bubbleEvents: object
        dateFormat: string
        disabled: boolean
        editorConfig: object
        endDateConfig: object
        endTimeConfig: object
        extraItems: string|object[]
        items: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        saveAndCloseOnEnter: boolean
        showDeleteButton: boolean
        showNameField: boolean
        startDateConfig: object
        startTimeConfig: object
        timeFormat: string
        weekStartDay: number
    }

    export class EditBase extends InstancePlugin {
        constructor(config?: Partial<EditBaseConfig>);
        onAfterSave(eventRecord: SchedulerEventModel): void;
        onBeforeSave(eventRecord: SchedulerEventModel): void;
    }

    type ResourceTimeRangesBaseConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
    }

    export abstract class ResourceTimeRangesBase extends InstancePlugin {
        constructor(config?: Partial<ResourceTimeRangesBaseConfig>);
    }

    type TimeSpanMenuBaseConfig = {
        bubbleEvents: object
        disabled: boolean
        items: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        menu: object
        menuConfig: object
        triggerEvent: string
        type: string
    }

    export abstract class TimeSpanMenuBase extends ContextMenuBase {
        constructor(config?: Partial<TimeSpanMenuBaseConfig>);
    }

    type TimeSpanRecordContextMenuBaseConfig = {
        bubbleEvents: object
        defaultItems: object
        disabled: boolean
        items: object|object[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        processItems: Function
        triggerEvent: string
    }

    export abstract class TimeSpanRecordContextMenuBase extends InstancePlugin {
        constructor(config?: Partial<TimeSpanRecordContextMenuBaseConfig>);
        abstract resolveRecord(): void;
        showContextMenuFor(record: TimeSpan, options?: object): void;
    }

    type TooltipBaseConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        allowOver: boolean
        anchor: boolean
        anchorToTarget: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoShow: boolean
        autoUpdate: boolean
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dismissDelay: number
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        forSelector: string
        getHtml: Function
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideDelay: number
        hideOnDelegateChange: boolean
        hideWhenEmpty: boolean
        hoverDelay: number
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        loadingMsg: string
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maximizable: boolean
        maximized: boolean
        minHeight: string|number
        minWidth: string|number
        modal: boolean
        monitorResize: boolean
        mouseOffsetX: number
        mouseOffsetY: number
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showOnClick: boolean
        showOnHover: boolean
        strips: object
        style: string
        tab: boolean|object
        tag: string
        tbar: object[]|object
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        trapFocus: boolean
        weight: number
        width: string|number
        x: number
        y: number
        onBeforeShow: Function
        onShow: Function
    }

    export class TooltipBase extends InstancePlugin {
        tooltip: Tooltip
        onBeforeShow: Function
        onShow: Function
        constructor(config?: Partial<TooltipBaseConfig>);
    }

    type ExcelExporterConfig = {
        bubbleEvents: object
        convertEmptyValueToEmptyString: boolean
        dateFormat: string
        disabled: boolean
        exporterClass: ScheduleTableExporter
        exporterConfig: object
        filename: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        zipcelx: object
    }

    export class ExcelExporter extends GridExcelExporter {
        constructor(config?: Partial<ExcelExporterConfig>);
    }

    type SchedulerPdfExportConfig = {
        alignRows: boolean
        bubbleEvents: object
        clientURL: string
        disabled: boolean
        exportDialog: object
        exportMask: string
        exportProgressMask: string
        exportServer: string
        exporterType: string
        exporters: Exporter[]
        fetchOptions: object
        fileFormat: string
        fileName: string
        footerTpl: Function
        headerTpl: Function
        keepPathName: boolean
        keepRegionSizes: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        openAfterExport: boolean
        openInNewTab: boolean
        orientation: string
        paperFormat: string
        rangeEnd: Date
        rangeStart: Date
        repeatHeader: boolean
        rowsRange: string
        scheduleRange: string
        sendAsBinary: boolean
        showErrorToast: boolean
        translateURLsToAbsolute: boolean|string
    }

    export class SchedulerPdfExport extends GridPdfExport {
        exportDialog: SchedulerExportDialog
        constructor(config?: Partial<SchedulerPdfExportConfig>);
    }

    type DependencyCreationConfig = {
        allowCreate: boolean
        allowDropOnEventBar: boolean
        creationTooltip: object
        showCreationTooltip: boolean
        terminalCls: string
        terminalSides: string[]
        onAfterDependencyCreateDrop: Function
        onBeforeDependencyCreateDrag: Function
        onBeforeDependencyCreateFinalize: Function
        onDependencyCreateDragStart: Function
        onDependencyCreateDrop: Function
        onDependencyValidationComplete: Function
        onDependencyValidationStart: Function
    }

    export class DependencyCreation {
        allowDropOnEventBar: boolean
        onAfterDependencyCreateDrop: Function
        onBeforeDependencyCreateDrag: Function
        onBeforeDependencyCreateFinalize: Function
        onDependencyCreateDragStart: Function
        onDependencyCreateDrop: Function
        onDependencyValidationComplete: Function
        onDependencyValidationStart: Function
        constructor(config?: Partial<DependencyCreationConfig>);
        abort(): void;
        hideTerminals(eventElement: HTMLElement): void;
        showTerminals(timeSpanRecord: TimeSpan, element: HTMLElement): void;
    }

    type RecurringEventEditConfig = {
        showRecurringUI: boolean
    }

    export class RecurringEventEdit {
        editRecurrenceButton: RecurrenceLegendButton
        recurrenceCombo: RecurrenceCombo
        constructor(config?: Partial<RecurringEventEditConfig>);
    }

    type SchedulerAssignmentModelConfig = {
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        drawDependencies: boolean
        event: string|number
        eventId: string|number
        id: string|number
        parentId: string|number|null
        parentIndex: number
        resource: string|number
        resourceId: string|number
    }

    export class SchedulerAssignmentModel extends Model implements AssignmentModelMixin {
        drawDependencies: boolean
        event: string|number
        eventId: string|number
        eventName: string
        isPersistable: boolean
        resource: string|number
        resourceId: string|number
        resourceName: string
        constructor(config?: Partial<SchedulerAssignmentModelConfig>);
        getResource(): SchedulerResourceModel;
        setAsync(field: string|object, value: any, silent?: boolean): void;
        toString(): string;
    }

    type DependencyBaseModelConfig = {
        bidirectional: boolean
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        from: string|number
        fromEvent: string|number|SchedulerEventModel
        fromSide: string
        id: string|number
        lag: number
        lagUnit: string
        parentId: string|number|null
        parentIndex: number
        to: string|number
        toEvent: string|number|SchedulerEventModel
        toSide: string
        type: number
    }

    export class DependencyBaseModel extends Model {
        static Type: object
        bidirectional: boolean
        cls: string
        from: string|number
        fromEvent: string|number|SchedulerEventModel
        fromSide: string
        fullLag: Duration
        hardType: number
        isPersistable: boolean
        lag: number
        lagUnit: string
        sourceEvent: SchedulerEventModel
        targetEvent: SchedulerEventModel
        to: string|number
        toEvent: string|number|SchedulerEventModel
        toSide: string
        type: number
        constructor(config?: Partial<DependencyBaseModelConfig>);
        getHardType(): number;
        getSourceEvent(): SchedulerEventModel;
        getTargetEvent(): SchedulerEventModel;
        highlight(cls: string): void;
        isHighlightedWith(cls: string): boolean;
        setAsync(field: string|object, value: any, silent?: boolean): void;
        setHardType(type: number): void;
        setLag(lag: number|string|object, lagUnit?: string): void;
        unhighlight(cls: string): void;
    }

    type SchedulerDependencyModelConfig = {
        bidirectional: boolean
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        from: string|number
        fromEvent: string|number|SchedulerEventModel
        fromSide: string
        id: string|number
        lag: number
        lagUnit: string
        parentId: string|number|null
        parentIndex: number
        to: string|number
        toEvent: string|number|SchedulerEventModel
        toSide: string
        type: number
    }

    export class SchedulerDependencyModel extends DependencyBaseModel {
        constructor(config?: Partial<SchedulerDependencyModelConfig>);
    }

    type SchedulerEventModelConfig = {
        allDay: boolean
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: DomClassList|string
        draggable: boolean
        duration: number
        durationUnit: string
        endDate: string|Date
        eventColor: string
        eventStyle: string
        exceptionDates: string|string[]
        iconCls: string
        id: string|number
        milestoneWidth: number
        name: string
        parentId: string|number|null
        parentIndex: number
        recurrenceRule: string
        resizable: boolean|string
        resourceId: string|number
        resources: string|number
        startDate: string|Date
        stickyContents: boolean
        style: string
    }

    export class SchedulerEventModel extends TimeSpan implements RecurringTimeSpan, EventModelMixin {
        allDay: boolean
        assignments: SchedulerAssignmentModel[]
        draggable: boolean
        duration: number
        endDate: string|Date
        eventColor: string
        eventStyle: string
        exceptionDates: string|string[]
        fullDuration: Duration
        id: string|number
        isDraggable: boolean
        isInterDay: boolean
        isOccurrence: boolean
        isPersistable: boolean
        isRecurring: boolean
        isResizable: boolean|string
        milestoneWidth: number
        occurrenceIndex: number
        predecessors: DependencyBaseModel[]
        recurrence: RecurrenceModel
        recurrenceModel: string
        recurrenceRule: string
        resizable: boolean|string
        resource: SchedulerResourceModel
        resourceId: string|number
        resources: SchedulerResourceModel[]
        startDate: string|Date
        stickyContents: boolean
        successors: DependencyBaseModel[]
        supportsRecurring: boolean
        constructor(config?: Partial<SchedulerEventModelConfig>);
        assign(resource: SchedulerResourceModel|string|number|SchedulerResourceModel[]|string[]|number[], removeExistingAssignments?: boolean): void;
        getOccurrencesForDateRange(startDate: Date, endDate?: Date): TimeSpan[];
        getResource(resourceId?: string): SchedulerResourceModel;
        hasException(date: Date): boolean;
        isAssignedTo(resource: SchedulerResourceModel|string|number): boolean;
        isEditable(fieldName: string): boolean;
        reassign(oldResourceId: SchedulerResourceModel|string|number, newResourceId: SchedulerResourceModel|string|number): void;
        remove(): void;
        setAsync(field: string|object, value: any, silent?: boolean): void;
        setRecurrence(recurrence: object|string|RecurrenceModel|Partial<RecurrenceModelConfig>, interval?: number, recurrenceEnd?: number|Date): void;
        shift(unit: string, amount: number): Promise<any>;
        unassign(resource?: SchedulerResourceModel|string|number): void;
    }

    type SchedulerProjectModelConfig = {
        assignmentModelClass: SchedulerAssignmentModel
        assignmentStore: SchedulerAssignmentStore|object|Partial<SchedulerAssignmentStoreConfig>
        assignmentStoreClass: SchedulerAssignmentStore|object|Partial<SchedulerAssignmentStoreConfig>
        assignmentsData: SchedulerAssignmentModel[]
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        dependenciesData: SchedulerDependencyModel[]
        dependencyModelClass: SchedulerDependencyModel
        dependencyStore: SchedulerDependencyStore|object|Partial<SchedulerDependencyStoreConfig>
        dependencyStoreClass: SchedulerDependencyStore|object|Partial<SchedulerDependencyStoreConfig>
        eventModelClass: SchedulerEventModel
        eventStore: SchedulerEventStore|object|Partial<SchedulerEventStoreConfig>
        eventStoreClass: SchedulerEventStore|object|Partial<SchedulerEventStoreConfig>
        eventsData: SchedulerEventModel[]
        id: string|number
        json: string
        parentId: string|number|null
        parentIndex: number
        resourceModelClass: SchedulerResourceModel
        resourceStore: SchedulerResourceStore|object|Partial<SchedulerResourceStoreConfig>
        resourceStoreClass: SchedulerResourceStore|object|Partial<SchedulerResourceStoreConfig>
        resourceTimeRangeStore: ResourceTimeRangeStore|object|Partial<ResourceTimeRangeStoreConfig>
        resourceTimeRangeStoreClass: ResourceTimeRangeStore|object|Partial<ResourceTimeRangeStoreConfig>
        resourceTimeRangesData: ResourceTimeRangeModel[]
        resourcesData: SchedulerResourceModel[]
        silenceInitialCommit: boolean
        stm: object|StateTrackingManager|Partial<StateTrackingManagerConfig>
        timeRangeStore: Store|object|Partial<StoreConfig>
        timeRangeStoreClass: Store|object|Partial<StoreConfig>
        timeRangesData: TimeSpan[]
        onChange: Function
    }

    export class SchedulerProjectModel extends Model implements ProjectModelMixin {
        assignmentStore: SchedulerAssignmentStore
        changes: object
        dependencyStore: SchedulerDependencyStore
        eventStore: SchedulerEventStore
        inlineData: object
        json: string
        resourceStore: SchedulerResourceStore
        resourceTimeRangeStore: ResourceTimeRangeStore
        stm: StateTrackingManager
        timeRangeStore: Store
        onChange: Function
        constructor(config?: Partial<SchedulerProjectModelConfig>);
        commitAsync(): Promise<any>;
        loadInlineData(dataPackage: object): void;
        toJSON(): object;
    }

    type RecurrenceModelConfig = {
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        count: number
        days: string[]
        endDate: Date
        frequency: string
        id: string|number
        interval: number
        monthDays: number[]
        months: number[]
        parentId: string|number|null
        parentIndex: number
        positions: number
    }

    export class RecurrenceModel extends Model {
        count: number
        days: string[]
        endDate: Date
        frequency: string
        interval: number
        isRecurrenceModel: boolean
        monthDays: number[]
        months: number[]
        positions: number
        rule: string
        timeSpan: TimeSpan
        constructor(config?: Partial<RecurrenceModelConfig>);
    }

    type SchedulerResourceModelConfig = {
        barMargin: number
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        eventColor: string
        eventLayout: string
        eventStyle: string
        expanded: boolean
        href: string
        iconCls: string
        id: string|number
        image: string
        imageUrl: string
        name: string
        parentId: string|number|null
        parentIndex: number
        resourceMargin: number
        rowHeight: number
        target: string
    }

    export class SchedulerResourceModel extends GridRowModel implements ResourceModelMixin {
        assignments: SchedulerAssignmentModel[]
        barMargin: number
        eventColor: string
        eventLayout: string
        eventStyle: string
        events: SchedulerEventModel[]
        id: string|number
        image: string
        imageUrl: string
        initials: string
        isPersistable: boolean
        name: string
        resourceMargin: number
        rowHeight: number
        constructor(config?: Partial<SchedulerResourceModelConfig>);
        getEvents(): SchedulerEventModel[];
        setAsync(field: string|object, value: any, silent?: boolean): void;
        unassignAll(): void;
    }

    type ResourceTimeRangeModelConfig = {
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: DomClassList|string
        duration: number
        durationUnit: string
        endDate: string|Date
        iconCls: string
        id: string|number
        name: string
        parentId: string|number|null
        parentIndex: number
        resourceId: string|number
        startDate: string|Date
        style: string
        timeRangeColor: string
    }

    export class ResourceTimeRangeModel extends TimeSpan {
        resourceId: string|number
        timeRangeColor: string
        constructor(config?: Partial<ResourceTimeRangeModelConfig>);
    }

    type TimeSpanConfig = {
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: DomClassList|string
        duration: number
        durationUnit: string
        endDate: string|Date
        iconCls: string
        id: string|number
        name: string
        parentId: string|number|null
        parentIndex: number
        startDate: string|Date
        style: string
    }

    export class TimeSpan extends Model {
        cls: DomClassList|string
        dates: Date[]
        duration: number
        durationMS: number
        durationUnit: string
        endDate: string|Date
        eventStore: SchedulerEventStore|EventStore
        fullDuration: Duration
        iconCls: string
        isScheduled: boolean
        name: string
        startDate: string|Date
        style: string
        wbsCode: string
        constructor(config?: Partial<TimeSpanConfig>);
        exportToICS(icsEventConfig?: object): void;
        forEachDate(func: Function, thisObj: object): void;
        isEditable(fieldName: string): boolean;
        setDuration(duration: number, durationUnit: string): void;
        setEndDate(date: Date, keepDuration?: boolean): void;
        setStartDate(date: Date, keepDuration?: boolean): void;
        setStartEndDate(start: Date, end: Date, silent?: boolean): void;
        shift(unit: string, amount: number): void;
        split(splitPoint?: number): TimeSpan;
    }

    type AssignmentModelMixinConfig = {
        drawDependencies: boolean
        event: string|number
        eventId: string|number
        resource: string|number
        resourceId: string|number
    }

    export class AssignmentModelMixin {
        drawDependencies: boolean
        event: string|number
        eventId: string|number
        eventName: string
        isPersistable: boolean
        resource: string|number
        resourceId: string|number
        resourceName: string
        constructor(config?: Partial<AssignmentModelMixinConfig>);
        getResource(): SchedulerResourceModel;
        setAsync(field: string|object, value: any, silent?: boolean): void;
        toString(): string;
    }

    type EventModelMixinConfig = {
        allDay: boolean
        draggable: boolean
        duration: number
        endDate: string|Date
        eventColor: string
        eventStyle: string
        id: string|number
        milestoneWidth: number
        resizable: boolean|string
        resourceId: string|number
        resources: string|number
        startDate: string|Date
        stickyContents: boolean
    }

    export class EventModelMixin {
        allDay: boolean
        assignments: SchedulerAssignmentModel[]
        draggable: boolean
        duration: number
        endDate: string|Date
        eventColor: string
        eventStyle: string
        fullDuration: Duration
        id: string|number
        isDraggable: boolean
        isInterDay: boolean
        isPersistable: boolean
        isResizable: boolean|string
        milestoneWidth: number
        predecessors: DependencyBaseModel[]
        resizable: boolean|string
        resource: SchedulerResourceModel
        resourceId: string|number
        resources: SchedulerResourceModel[]
        startDate: string|Date
        stickyContents: boolean
        successors: DependencyBaseModel[]
        constructor(config?: Partial<EventModelMixinConfig>);
        assign(resource: SchedulerResourceModel|string|number|SchedulerResourceModel[]|string[]|number[], removeExistingAssignments?: boolean): void;
        getResource(resourceId?: string): SchedulerResourceModel;
        isAssignedTo(resource: SchedulerResourceModel|string|number): boolean;
        isEditable(fieldName: string): boolean;
        reassign(oldResourceId: SchedulerResourceModel|string|number, newResourceId: SchedulerResourceModel|string|number): void;
        setAsync(field: string|object, value: any, silent?: boolean): void;
        shift(unit: string, amount: number): Promise<any>;
        unassign(resource?: SchedulerResourceModel|string|number): void;
    }

    type ProjectModelMixinConfig = {
        assignmentModelClass: SchedulerAssignmentModel
        assignmentStore: SchedulerAssignmentStore|object|Partial<SchedulerAssignmentStoreConfig>
        assignmentStoreClass: SchedulerAssignmentStore|object|Partial<SchedulerAssignmentStoreConfig>
        assignmentsData: SchedulerAssignmentModel[]
        dependenciesData: SchedulerDependencyModel[]
        dependencyModelClass: SchedulerDependencyModel
        dependencyStore: SchedulerDependencyStore|object|Partial<SchedulerDependencyStoreConfig>
        dependencyStoreClass: SchedulerDependencyStore|object|Partial<SchedulerDependencyStoreConfig>
        eventModelClass: SchedulerEventModel
        eventStore: SchedulerEventStore|object|Partial<SchedulerEventStoreConfig>
        eventStoreClass: SchedulerEventStore|object|Partial<SchedulerEventStoreConfig>
        eventsData: SchedulerEventModel[]
        json: string
        resourceModelClass: SchedulerResourceModel
        resourceStore: SchedulerResourceStore|object|Partial<SchedulerResourceStoreConfig>
        resourceStoreClass: SchedulerResourceStore|object|Partial<SchedulerResourceStoreConfig>
        resourceTimeRangeStore: ResourceTimeRangeStore|object|Partial<ResourceTimeRangeStoreConfig>
        resourceTimeRangeStoreClass: ResourceTimeRangeStore|object|Partial<ResourceTimeRangeStoreConfig>
        resourceTimeRangesData: ResourceTimeRangeModel[]
        resourcesData: SchedulerResourceModel[]
        stm: object|StateTrackingManager|Partial<StateTrackingManagerConfig>
        timeRangeStore: Store|object|Partial<StoreConfig>
        timeRangeStoreClass: Store|object|Partial<StoreConfig>
        timeRangesData: TimeSpan[]
        onChange: Function
    }

    export class ProjectModelMixin {
        assignmentStore: SchedulerAssignmentStore|SchedulerProAssignmentStore
        changes: object
        dependencyStore: SchedulerDependencyStore|SchedulerProDependencyStore
        eventStore: SchedulerEventStore|EventStore
        inlineData: object
        json: string
        resourceStore: SchedulerResourceStore|SchedulerProResourceStore
        resourceTimeRangeStore: ResourceTimeRangeStore
        stm: StateTrackingManager
        timeRangeStore: Store
        onChange: Function
        constructor(config?: Partial<ProjectModelMixinConfig>);
        commitAsync(): Promise<any>;
        loadInlineData(dataPackage: object): void;
        toJSON(): object;
    }

    type RecurringTimeSpanConfig = {
        exceptionDates: string|string[]
        recurrenceRule: string
    }

    export class RecurringTimeSpan {
        exceptionDates: string|string[]
        isOccurrence: boolean
        isRecurring: boolean
        occurrenceIndex: number
        recurrence: RecurrenceModel
        recurrenceModel: string
        recurrenceRule: string
        supportsRecurring: boolean
        constructor(config?: Partial<RecurringTimeSpanConfig>);
        getOccurrencesForDateRange(startDate: Date, endDate?: Date): TimeSpan[];
        hasException(date: Date): boolean;
        remove(): void;
        setRecurrence(recurrence: object|string|RecurrenceModel|Partial<RecurrenceModelConfig>, interval?: number, recurrenceEnd?: number|Date): void;
    }

    type ResourceModelMixinConfig = {
        barMargin: number
        eventColor: string
        eventLayout: string
        eventStyle: string
        id: string|number
        image: string
        imageUrl: string
        name: string
        resourceMargin: number
        rowHeight: number
    }

    export class ResourceModelMixin {
        assignments: SchedulerAssignmentModel[]
        barMargin: number
        eventColor: string
        eventLayout: string
        eventStyle: string
        events: SchedulerEventModel[]
        id: string|number
        image: string
        imageUrl: string
        initials: string
        isPersistable: boolean
        name: string
        resourceMargin: number
        rowHeight: number
        constructor(config?: Partial<ResourceModelMixinConfig>);
        getEvents(): SchedulerEventModel[];
        setAsync(field: string|object, value: any, silent?: boolean): void;
        unassignAll(): void;
    }

    export class PresetManagerSingleton extends PresetStore {
        deletePreset(id: string): void;
        normalizePreset(presetOrId: string|object): ViewPreset;
        registerPreset(id: string, config: object): ViewPreset;
    }

    export const PresetManager : PresetManagerSingleton

    type PresetStoreConfig = {
        allowNoId: boolean
        autoCommit: boolean
        autoTree: boolean
        bubbleEvents: object
        chainedFields: string[]
        chainedFilterFn: Function
        data: object[]|Model[]|Partial<ModelConfig>[]
        doRelayToMaster: string[]
        dontRelayToMaster: string
        fields: string[]|object[]|DataField[]|Partial<DataFieldConfig>[]
        filters: object|object[]
        groupers: object[]
        id: string|number
        keepUncommittedChanges: boolean
        listeners: object
        masterStore: Store
        modelClass: typeof Model
        reapplyFilterOnAdd: boolean
        reapplyFilterOnUpdate: boolean
        reapplySortersOnAdd: boolean
        sorters: object[]|string[]
        stm: StateTrackingManager
        storage: Collection|object|Partial<CollectionConfig>
        syncDataOnLoad: boolean|object
        transformFlatData: boolean
        tree: boolean
        useLocaleSort: boolean|string|object
        useRawData: boolean|object
        zoomOrder: number
    }

    export class PresetStore extends Store {
        constructor(config?: Partial<PresetStoreConfig>);
    }

    type ViewPresetConfig = {
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        columnLinesFor: number
        defaultSpan: number
        displayDateFormat: string
        headers: object[]
        id: string|number
        mainHeaderLevel: number
        name: string
        parentId: string|number|null
        parentIndex: number
        rowHeight: number
        shiftIncrement: number
        shiftUnit: string
        tickHeight: number
        tickWidth: number
        timeResolution: object
    }

    export class ViewPreset extends Model {
        columnLinesFor: number
        defaultSpan: number
        displayDateFormat: string
        headers: object[]
        mainHeaderLevel: number
        name: string
        rowHeight: number
        shiftIncrement: number
        shiftUnit: string
        tickHeight: number
        tickWidth: number
        timeResolution: object
        constructor(config?: Partial<ViewPresetConfig>);
    }

    type ScheduleTableExporterConfig = {
        columns: string[]|object[]
        defaultColumnWidth: number
        eventColumns: string[]|object[]
        exportDateAsInstance: boolean
        includeUnassigned: boolean
        indent: boolean
        indentationSymbol: string
        localeClass: Base
        localizableProperties: string[]
        showGroupHeader: boolean
        target: Grid
    }

    export class ScheduleTableExporter extends TableExporter implements Localizable {
        localeManager: typeof LocaleManager
        constructor(config?: Partial<ScheduleTableExporterConfig>);
        static optionalL(text: string, templateData?: object): string;
        L(text: string, templateData?: object): string;
        updateLocalization(): void;
    }

    type ResourceHeaderConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        columnWidth: number
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        fillWidth: boolean
        fitWidth: boolean
        flex: number|string
        floating: boolean
        headerRenderer: Function
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showAvatars: boolean
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class ResourceHeader extends Widget {
        fillWidth: boolean
        fitWidth: boolean
        constructor(config?: Partial<ResourceHeaderConfig>);
        refresh(): void;
    }

    type SchedulerFeaturesType = {
        cellEdit: GridCellEdit
        cellMenu: CellMenu
        cellTooltip: CellTooltip
        columnAutoWidth: ColumnAutoWidth
        columnDragToolbar: ColumnDragToolbar
        columnLines: ColumnLines
        columnPicker: ColumnPicker
        columnReorder: ColumnReorder
        columnResize: ColumnResize
        contextMenu: ContextMenu
        dependencies: SchedulerDependencies
        dependencyEdit: SchedulerDependencyEdit
        eventContextMenu: EventContextMenu
        eventCopyPaste: EventCopyPaste
        eventDrag: EventDrag
        eventDragCreate: EventDragCreate
        eventDragSelect: EventDragSelect
        eventEdit: EventEdit
        eventFilter: EventFilter
        eventMenu: EventMenu
        eventResize: SchedulerEventResize
        eventTooltip: EventTooltip
        excelExporter: ExcelExporter
        filter: Filter
        filterBar: FilterBar
        group: Group
        groupSummary: GroupSummary
        headerContextMenu: HeaderContextMenu
        headerMenu: HeaderMenu
        headerZoom: HeaderZoom
        labels: SchedulerLabels
        nonWorkingTime: NonWorkingTime
        pan: Pan
        pdfExport: SchedulerPdfExport
        quickFind: QuickFind
        regionResize: RegionResize
        resourceTimeRanges: ResourceTimeRanges
        rowCopyPaste: RowCopyPaste
        rowReorder: RowReorder
        scheduleContext: ScheduleContext
        scheduleContextMenu: ScheduleContextMenu
        scheduleMenu: ScheduleMenu
        scheduleTooltip: ScheduleTooltip
        search: Search
        simpleEventEdit: SimpleEventEdit
        sort: Sort
        stickyCells: StickyCells
        stickyEvents: StickyEvents
        stripe: Stripe
        summary: Summary
        timeAxisHeaderMenu: TimeAxisHeaderMenu
        timeRanges: TimeRanges
        tree: Tree
    }

    type SchedulerFeaturesConfigType = {
        cellEdit: string|boolean|Partial<GridCellEditConfig>
        cellMenu: string|boolean|Partial<CellMenuConfig>
        cellTooltip: string|boolean|Partial<CellTooltipConfig>
        columnAutoWidth: string|boolean|Partial<ColumnAutoWidthConfig>
        columnDragToolbar: string|boolean|Partial<ColumnDragToolbarConfig>
        columnLines: string|boolean|Partial<ColumnLinesConfig>
        columnPicker: string|boolean|Partial<ColumnPickerConfig>
        columnReorder: string|boolean|Partial<ColumnReorderConfig>
        columnResize: string|boolean|Partial<ColumnResizeConfig>
        contextMenu: string|boolean|Partial<ContextMenuConfig>
        dependencies: string|boolean|Partial<SchedulerDependenciesConfig>
        dependencyEdit: string|boolean|Partial<SchedulerDependencyEditConfig>
        eventContextMenu: string|boolean|Partial<EventContextMenuConfig>
        eventCopyPaste: string|boolean|Partial<EventCopyPasteConfig>
        eventDrag: string|boolean|Partial<EventDragConfig>
        eventDragCreate: string|boolean|Partial<EventDragCreateConfig>
        eventDragSelect: string|boolean|Partial<EventDragSelectConfig>
        eventEdit: string|boolean|Partial<EventEditConfig>
        eventFilter: string|boolean|Partial<EventFilterConfig>
        eventMenu: string|boolean|Partial<EventMenuConfig>
        eventResize: string|boolean|Partial<SchedulerEventResizeConfig>
        eventTooltip: string|boolean|Partial<EventTooltipConfig>
        excelExporter: string|boolean|Partial<ExcelExporterConfig>
        filter: string|boolean|Partial<FilterConfig>
        filterBar: string|boolean|Partial<FilterBarConfig>
        group: string|boolean|Partial<GroupConfig>
        groupSummary: string|boolean|Partial<GroupSummaryConfig>
        headerContextMenu: string|boolean|Partial<HeaderContextMenuConfig>
        headerMenu: string|boolean|Partial<HeaderMenuConfig>
        headerZoom: string|boolean|Partial<HeaderZoomConfig>
        labels: string|boolean|Partial<SchedulerLabelsConfig>
        nonWorkingTime: string|boolean|Partial<NonWorkingTimeConfig>
        pan: string|boolean|Partial<PanConfig>
        pdfExport: string|boolean|Partial<SchedulerPdfExportConfig>
        quickFind: string|boolean|Partial<QuickFindConfig>
        regionResize: string|boolean|Partial<RegionResizeConfig>
        resourceTimeRanges: string|boolean|Partial<ResourceTimeRangesConfig>
        rowCopyPaste: string|boolean|Partial<RowCopyPasteConfig>
        rowReorder: string|boolean|Partial<RowReorderConfig>
        scheduleContext: string|boolean|Partial<ScheduleContextConfig>
        scheduleContextMenu: string|boolean|Partial<ScheduleContextMenuConfig>
        scheduleMenu: string|boolean|Partial<ScheduleMenuConfig>
        scheduleTooltip: string|boolean|Partial<ScheduleTooltipConfig>
        search: string|boolean|Partial<SearchConfig>
        simpleEventEdit: string|boolean|Partial<SimpleEventEditConfig>
        sort: string|boolean|Partial<SortConfig>
        stickyCells: string|boolean|Partial<StickyCellsConfig>
        stickyEvents: string|boolean|Partial<StickyEventsConfig>
        stripe: string|boolean|Partial<StripeConfig>
        summary: string|boolean|Partial<SummaryConfig>
        timeAxisHeaderMenu: string|boolean|Partial<TimeAxisHeaderMenuConfig>
        timeRanges: string|boolean|Partial<TimeRangesConfig>
        tree: string|boolean|Partial<TreeConfig>
    }

    type SchedulerConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        allowCreate: boolean
        allowDropOnEventBar: boolean
        allowOver: boolean
        allowOverlap: boolean
        anchor: boolean
        anchorToTarget: boolean
        animateRemovingRows: boolean
        appendTo: HTMLElement|string
        assignmentStore: SchedulerAssignmentStore|object|Partial<SchedulerAssignmentStoreConfig>
        assignments: SchedulerAssignmentModel[]|object[]|Partial<SchedulerAssignmentModelConfig>[]
        autoAdjustTimeAxis: boolean
        autoClose: boolean
        autoHeight: boolean
        autoShow: boolean
        barMargin: number
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        bufferCoef: number
        bufferThreshold: number
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        columnLines: boolean
        columns: object[]|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        contextMenuTriggerEvent: string
        createEventOnDblClick: boolean|object
        creationTooltip: object
        crudManager: object|CrudManager|Partial<CrudManagerConfig>
        crudManagerClass: CrudManager
        data: object[]
        dataset: object
        defaultBindProperty: string
        defaultRegion: string
        defaultResourceImageName: string
        defaults: object
        dependencies: SchedulerDependencyModel[]|object[]|Partial<SchedulerDependencyModelConfig>[]
        dependencyStore: SchedulerDependencyStore|object|Partial<SchedulerDependencyStoreConfig>
        descriptionRenderer: Function
        destroyStore: boolean
        destroyStores: boolean
        disableGridRowModelWarning: boolean
        disabled: boolean
        dismissDelay: number
        displayDateFormat: string
        dock: string
        draggable: boolean|object
        durationDisplayPrecision: number|boolean
        emptyText: string
        enableDeleteKey: boolean
        enableEventAnimations: boolean
        enableRecurringEvents: boolean
        enableSticky: boolean
        enableTextSelection: boolean
        enableUndoRedoKeys: boolean
        endDate: Date|string
        endParamName: string
        eventBarTextField: string
        eventBodyTemplate: Function
        eventColor: string
        eventLayout: string
        eventRenderer: Function
        eventRendererThisObj: object
        eventSelectionDisabled: boolean
        eventStore: SchedulerEventStore|object|Partial<SchedulerEventStoreConfig>
        eventStyle: string
        events: SchedulerEventModel[]|object[]|Partial<SchedulerEventModelConfig>[]
        features: Partial<SchedulerFeaturesConfigType>
        fillLastColumn: boolean
        fillTicks: boolean
        fixedRowHeight: boolean
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        forSelector: string
        forceFit: boolean
        fullRowRefresh: boolean
        getDateConstraints: Function
        getHtml: Function
        getRowHeight: Function
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideDelay: number
        hideHeaders: boolean
        hideOnDelegateChange: boolean
        hideWhenEmpty: boolean
        highlightPredecessors: boolean
        highlightSuccessors: boolean
        horizontalEventSorterFn: Function
        hoverDelay: number
        html: string
        htmlCls: string|object
        id: string
        infiniteScroll: boolean
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        loadMask: string|object|null
        loadMaskDefaults: object|Mask|Partial<MaskConfig>
        loadMaskError: object|Mask|Partial<MaskConfig>
        loadingMsg: string
        localeClass: Base
        localizableProperties: string[]
        longPressTime: number
        maintainSelectionOnDatasetChange: boolean
        managedEventSizing: boolean
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maxZoomLevel: number
        maximizable: boolean
        maximized: boolean
        milestoneAlign: string
        milestoneCharWidth: number
        milestoneLayoutMode: string
        milestoneTextPosition: string
        minHeight: string|number
        minWidth: string|number
        minZoomLevel: number
        modal: boolean
        mode: string
        monitorResize: boolean
        mouseOffsetX: number
        mouseOffsetY: number
        multiEventSelect: boolean
        namedItems: object
        owner: Widget
        partner: TimelineBase
        passStartEndParameters: boolean
        plugins: Function[]
        positioned: boolean
        preCalculateHeightLimit: number
        preserveFocusOnDatasetChange: boolean
        preserveScrollOnDatasetChange: boolean
        presets: object[]
        preventTooltipOnTouch: boolean
        project: SchedulerProjectModel|object|Partial<SchedulerProjectModelConfig>
        readOnly: boolean
        ref: string
        removeUnassignedEvent: boolean
        resizeToFitIncludesHeader: boolean
        resourceColumns: object
        resourceImageExtension: string
        resourceImagePath: string
        resourceMargin: number
        resourceStore: SchedulerResourceStore|object|Partial<SchedulerResourceStoreConfig>
        resourceTimeRangeStore: ResourceTimeRangeStore|object|Partial<ResourceTimeRangeStoreConfig>
        resourceTimeRanges: ResourceTimeRangeModel[]|object[]|Partial<ResourceTimeRangeModelConfig>[]
        resources: SchedulerResourceModel[]|object[]|Partial<SchedulerResourceModelConfig>[]
        responsiveLevels: object
        ripple: boolean|object
        rootElement: ShadowRoot
        rowHeight: number
        scrollAction: string
        scrollManager: object|ScrollManager|Partial<ScrollManagerConfig>
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        scrollerClass: Scroller
        selectionMode: object
        showAnimation: boolean|object
        showCreationTooltip: boolean
        showDirty: boolean
        showOnClick: boolean
        showOnHover: boolean
        showRecurringUI: boolean
        showRemoveRowInContextMenu: boolean
        snap: boolean
        snapRelativeToEventStartDate: boolean
        startDate: Date|string
        startParamName: string
        stickyHeaders: boolean
        store: Store|object|Partial<StoreConfig>
        strips: object
        style: string
        subGridConfigs: object
        suppressFit: boolean
        syncMask: string|object|null
        tab: boolean|object
        tag: string
        tbar: object[]|object
        terminalCls: string
        terminalSides: string[]
        textAlign: string
        textContent: boolean
        tickSize: number
        timeAxis: object|TimeAxis|Partial<TimeAxisConfig>
        timeRangeStore: Store|object|Partial<StoreConfig>
        timeRanges: TimeSpan[]|object[]|Partial<TimeSpanConfig>[]
        title: string
        tools: object
        tooltip: string|object
        transitionDuration: number
        trapFocus: boolean
        triggerSelectionChangeOnRemove: boolean
        useInitialAnimation: boolean|string
        verticalTimeAxisColumn: object
        viewPreset: string|object
        visibleDate: Date|object
        visibleZoomFactor: number
        weekStartDay: number
        weight: number
        width: string|number
        workingTime: object
        x: number
        y: number
        zoomKeepsOriginalTimespan: boolean
        zoomOnMouseWheel: boolean
        zoomOnTimeAxisDoubleClick: boolean
    }

    export class Scheduler extends SchedulerBase {
        features: SchedulerFeaturesType
        constructor(config?: Partial<SchedulerConfig>);
    }

    type SchedulerBaseFeaturesType = {
        cellEdit: GridCellEdit
        cellMenu: CellMenu
        cellTooltip: CellTooltip
        columnAutoWidth: ColumnAutoWidth
        columnDragToolbar: ColumnDragToolbar
        columnLines: ColumnLines
        columnPicker: ColumnPicker
        columnReorder: ColumnReorder
        columnResize: ColumnResize
        contextMenu: ContextMenu
        dependencies: SchedulerDependencies
        dependencyEdit: SchedulerDependencyEdit
        eventContextMenu: EventContextMenu
        eventCopyPaste: EventCopyPaste
        eventDrag: EventDrag
        eventDragCreate: EventDragCreate
        eventDragSelect: EventDragSelect
        eventEdit: EventEdit
        eventFilter: EventFilter
        eventMenu: EventMenu
        eventResize: SchedulerEventResize
        eventTooltip: EventTooltip
        excelExporter: ExcelExporter
        filter: Filter
        filterBar: FilterBar
        group: Group
        groupSummary: GroupSummary
        headerContextMenu: HeaderContextMenu
        headerMenu: HeaderMenu
        headerZoom: HeaderZoom
        labels: SchedulerLabels
        nonWorkingTime: NonWorkingTime
        pan: Pan
        pdfExport: SchedulerPdfExport
        quickFind: QuickFind
        regionResize: RegionResize
        resourceTimeRanges: ResourceTimeRanges
        rowCopyPaste: RowCopyPaste
        rowReorder: RowReorder
        scheduleContext: ScheduleContext
        scheduleContextMenu: ScheduleContextMenu
        scheduleMenu: ScheduleMenu
        scheduleTooltip: ScheduleTooltip
        search: Search
        simpleEventEdit: SimpleEventEdit
        sort: Sort
        stickyCells: StickyCells
        stickyEvents: StickyEvents
        stripe: Stripe
        summary: Summary
        timeAxisHeaderMenu: TimeAxisHeaderMenu
        timeRanges: TimeRanges
        tree: Tree
    }

    type SchedulerBaseFeaturesConfigType = {
        cellEdit: string|boolean|Partial<GridCellEditConfig>
        cellMenu: string|boolean|Partial<CellMenuConfig>
        cellTooltip: string|boolean|Partial<CellTooltipConfig>
        columnAutoWidth: string|boolean|Partial<ColumnAutoWidthConfig>
        columnDragToolbar: string|boolean|Partial<ColumnDragToolbarConfig>
        columnLines: string|boolean|Partial<ColumnLinesConfig>
        columnPicker: string|boolean|Partial<ColumnPickerConfig>
        columnReorder: string|boolean|Partial<ColumnReorderConfig>
        columnResize: string|boolean|Partial<ColumnResizeConfig>
        contextMenu: string|boolean|Partial<ContextMenuConfig>
        dependencies: string|boolean|Partial<SchedulerDependenciesConfig>
        dependencyEdit: string|boolean|Partial<SchedulerDependencyEditConfig>
        eventContextMenu: string|boolean|Partial<EventContextMenuConfig>
        eventCopyPaste: string|boolean|Partial<EventCopyPasteConfig>
        eventDrag: string|boolean|Partial<EventDragConfig>
        eventDragCreate: string|boolean|Partial<EventDragCreateConfig>
        eventDragSelect: string|boolean|Partial<EventDragSelectConfig>
        eventEdit: string|boolean|Partial<EventEditConfig>
        eventFilter: string|boolean|Partial<EventFilterConfig>
        eventMenu: string|boolean|Partial<EventMenuConfig>
        eventResize: string|boolean|Partial<SchedulerEventResizeConfig>
        eventTooltip: string|boolean|Partial<EventTooltipConfig>
        excelExporter: string|boolean|Partial<ExcelExporterConfig>
        filter: string|boolean|Partial<FilterConfig>
        filterBar: string|boolean|Partial<FilterBarConfig>
        group: string|boolean|Partial<GroupConfig>
        groupSummary: string|boolean|Partial<GroupSummaryConfig>
        headerContextMenu: string|boolean|Partial<HeaderContextMenuConfig>
        headerMenu: string|boolean|Partial<HeaderMenuConfig>
        headerZoom: string|boolean|Partial<HeaderZoomConfig>
        labels: string|boolean|Partial<SchedulerLabelsConfig>
        nonWorkingTime: string|boolean|Partial<NonWorkingTimeConfig>
        pan: string|boolean|Partial<PanConfig>
        pdfExport: string|boolean|Partial<SchedulerPdfExportConfig>
        quickFind: string|boolean|Partial<QuickFindConfig>
        regionResize: string|boolean|Partial<RegionResizeConfig>
        resourceTimeRanges: string|boolean|Partial<ResourceTimeRangesConfig>
        rowCopyPaste: string|boolean|Partial<RowCopyPasteConfig>
        rowReorder: string|boolean|Partial<RowReorderConfig>
        scheduleContext: string|boolean|Partial<ScheduleContextConfig>
        scheduleContextMenu: string|boolean|Partial<ScheduleContextMenuConfig>
        scheduleMenu: string|boolean|Partial<ScheduleMenuConfig>
        scheduleTooltip: string|boolean|Partial<ScheduleTooltipConfig>
        search: string|boolean|Partial<SearchConfig>
        simpleEventEdit: string|boolean|Partial<SimpleEventEditConfig>
        sort: string|boolean|Partial<SortConfig>
        stickyCells: string|boolean|Partial<StickyCellsConfig>
        stickyEvents: string|boolean|Partial<StickyEventsConfig>
        stripe: string|boolean|Partial<StripeConfig>
        summary: string|boolean|Partial<SummaryConfig>
        timeAxisHeaderMenu: string|boolean|Partial<TimeAxisHeaderMenuConfig>
        timeRanges: string|boolean|Partial<TimeRangesConfig>
        tree: string|boolean|Partial<TreeConfig>
    }

    type SchedulerBaseConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        allowCreate: boolean
        allowDropOnEventBar: boolean
        allowOver: boolean
        allowOverlap: boolean
        anchor: boolean
        anchorToTarget: boolean
        animateRemovingRows: boolean
        appendTo: HTMLElement|string
        assignmentStore: SchedulerAssignmentStore|object|Partial<SchedulerAssignmentStoreConfig>
        assignments: SchedulerAssignmentModel[]|object[]|Partial<SchedulerAssignmentModelConfig>[]
        autoAdjustTimeAxis: boolean
        autoClose: boolean
        autoHeight: boolean
        autoShow: boolean
        barMargin: number
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        bufferCoef: number
        bufferThreshold: number
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        columnLines: boolean
        columns: object[]|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        contextMenuTriggerEvent: string
        createEventOnDblClick: boolean|object
        creationTooltip: object
        crudManager: object|CrudManager|Partial<CrudManagerConfig>
        crudManagerClass: CrudManager
        data: object[]
        dataset: object
        defaultBindProperty: string
        defaultRegion: string
        defaultResourceImageName: string
        defaults: object
        dependencies: SchedulerDependencyModel[]|object[]|Partial<SchedulerDependencyModelConfig>[]
        dependencyStore: SchedulerDependencyStore|object|Partial<SchedulerDependencyStoreConfig>
        descriptionRenderer: Function
        destroyStore: boolean
        destroyStores: boolean
        disableGridRowModelWarning: boolean
        disabled: boolean
        dismissDelay: number
        displayDateFormat: string
        dock: string
        draggable: boolean|object
        durationDisplayPrecision: number|boolean
        emptyText: string
        enableDeleteKey: boolean
        enableEventAnimations: boolean
        enableRecurringEvents: boolean
        enableSticky: boolean
        enableTextSelection: boolean
        enableUndoRedoKeys: boolean
        endDate: Date|string
        endParamName: string
        eventBarTextField: string
        eventBodyTemplate: Function
        eventColor: string
        eventLayout: string
        eventRenderer: Function
        eventRendererThisObj: object
        eventSelectionDisabled: boolean
        eventStore: SchedulerEventStore|object|Partial<SchedulerEventStoreConfig>
        eventStyle: string
        events: SchedulerEventModel[]|object[]|Partial<SchedulerEventModelConfig>[]
        features: Partial<SchedulerBaseFeaturesConfigType>
        fillLastColumn: boolean
        fillTicks: boolean
        fixedRowHeight: boolean
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        forSelector: string
        forceFit: boolean
        fullRowRefresh: boolean
        getDateConstraints: Function
        getHtml: Function
        getRowHeight: Function
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideDelay: number
        hideHeaders: boolean
        hideOnDelegateChange: boolean
        hideWhenEmpty: boolean
        highlightPredecessors: boolean
        highlightSuccessors: boolean
        horizontalEventSorterFn: Function
        hoverDelay: number
        html: string
        htmlCls: string|object
        id: string
        infiniteScroll: boolean
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        loadMask: string|object|null
        loadMaskDefaults: object|Mask|Partial<MaskConfig>
        loadMaskError: object|Mask|Partial<MaskConfig>
        loadingMsg: string
        localeClass: Base
        localizableProperties: string[]
        longPressTime: number
        maintainSelectionOnDatasetChange: boolean
        managedEventSizing: boolean
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maxZoomLevel: number
        maximizable: boolean
        maximized: boolean
        milestoneAlign: string
        milestoneCharWidth: number
        milestoneLayoutMode: string
        milestoneTextPosition: string
        minHeight: string|number
        minWidth: string|number
        minZoomLevel: number
        modal: boolean
        mode: string
        monitorResize: boolean
        mouseOffsetX: number
        mouseOffsetY: number
        multiEventSelect: boolean
        namedItems: object
        owner: Widget
        partner: TimelineBase
        passStartEndParameters: boolean
        plugins: Function[]
        positioned: boolean
        preCalculateHeightLimit: number
        preserveFocusOnDatasetChange: boolean
        preserveScrollOnDatasetChange: boolean
        presets: object[]
        preventTooltipOnTouch: boolean
        project: SchedulerProjectModel|object|Partial<SchedulerProjectModelConfig>
        readOnly: boolean
        ref: string
        removeUnassignedEvent: boolean
        resizeToFitIncludesHeader: boolean
        resourceColumns: object
        resourceImageExtension: string
        resourceImagePath: string
        resourceMargin: number
        resourceStore: SchedulerResourceStore|object|Partial<SchedulerResourceStoreConfig>
        resourceTimeRangeStore: ResourceTimeRangeStore|object|Partial<ResourceTimeRangeStoreConfig>
        resourceTimeRanges: ResourceTimeRangeModel[]|object[]|Partial<ResourceTimeRangeModelConfig>[]
        resources: SchedulerResourceModel[]|object[]|Partial<SchedulerResourceModelConfig>[]
        responsiveLevels: object
        ripple: boolean|object
        rootElement: ShadowRoot
        rowHeight: number
        scrollAction: string
        scrollManager: object|ScrollManager|Partial<ScrollManagerConfig>
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        scrollerClass: Scroller
        selectionMode: object
        showAnimation: boolean|object
        showCreationTooltip: boolean
        showDirty: boolean
        showOnClick: boolean
        showOnHover: boolean
        showRecurringUI: boolean
        showRemoveRowInContextMenu: boolean
        snap: boolean
        snapRelativeToEventStartDate: boolean
        startDate: Date|string
        startParamName: string
        stickyHeaders: boolean
        store: Store|object|Partial<StoreConfig>
        strips: object
        style: string
        subGridConfigs: object
        suppressFit: boolean
        syncMask: string|object|null
        tab: boolean|object
        tag: string
        tbar: object[]|object
        terminalCls: string
        terminalSides: string[]
        textAlign: string
        textContent: boolean
        tickSize: number
        timeAxis: object|TimeAxis|Partial<TimeAxisConfig>
        timeRangeStore: Store|object|Partial<StoreConfig>
        timeRanges: TimeSpan[]|object[]|Partial<TimeSpanConfig>[]
        title: string
        tools: object
        tooltip: string|object
        transitionDuration: number
        trapFocus: boolean
        triggerSelectionChangeOnRemove: boolean
        useInitialAnimation: boolean|string
        verticalTimeAxisColumn: object
        viewPreset: string|object
        visibleDate: Date|object
        visibleZoomFactor: number
        weekStartDay: number
        weight: number
        width: string|number
        workingTime: object
        x: number
        y: number
        zoomKeepsOriginalTimespan: boolean
        zoomOnMouseWheel: boolean
        zoomOnTimeAxisDoubleClick: boolean
        onAfterDependencyCreateDrop: Function
        onAfterDependencySave: Function
        onAfterDragCreate: Function
        onAfterEventDrop: Function
        onAfterEventSave: Function
        onAssignmentSelectionChange: Function
        onBeforeAssignmentDelete: Function
        onBeforeDependencyAdd: Function
        onBeforeDependencyCreateDrag: Function
        onBeforeDependencyCreateFinalize: Function
        onBeforeDependencyDelete: Function
        onBeforeDependencyEdit: Function
        onBeforeDependencyEditShow: Function
        onBeforeDependencySave: Function
        onBeforeDestroy: Function
        onBeforeDragCreate: Function
        onBeforeDragCreateFinalize: Function
        onBeforeEventAdd: Function
        onBeforeEventDelete: Function
        onBeforeEventDrag: Function
        onBeforeEventDropFinalize: Function
        onBeforeEventEdit: Function
        onBeforeEventEditShow: Function
        onBeforeEventResize: Function
        onBeforeEventResizeFinalize: Function
        onBeforeEventSave: Function
        onBeforeExport: Function
        onBeforePresetChange: Function
        onCatchAll: Function
        onContextMenuItem: Function
        onContextMenuToggleItem: Function
        onDataChange: Function
        onDependencyClick: Function
        onDependencyCreateDragStart: Function
        onDependencyCreateDrop: Function
        onDependencyDblClick: Function
        onDependencyMouseOut: Function
        onDependencyMouseOver: Function
        onDependencyValidationComplete: Function
        onDependencyValidationStart: Function
        onDestroy: Function
        onDragCreateEnd: Function
        onDragCreateStart: Function
        onEventClick: Function
        onEventContextMenu: Function
        onEventDblClick: Function
        onEventDrag: Function
        onEventDragAbort: Function
        onEventDragStart: Function
        onEventDrop: Function
        onEventEditBeforeSetRecord: Function
        onEventKeyDown: Function
        onEventKeyUp: Function
        onEventMenuBeforeShow: Function
        onEventMenuItem: Function
        onEventMenuShow: Function
        onEventMouseDown: Function
        onEventMouseOut: Function
        onEventMouseOver: Function
        onEventMouseUp: Function
        onEventPartialResize: Function
        onEventResizeEnd: Function
        onEventResizeStart: Function
        onEventSelectionChange: Function
        onExport: Function
        onHeaderMenuBeforeShow: Function
        onHeaderMenuItem: Function
        onHeaderMenuShow: Function
        onHeaderMenuToggleItem: Function
        onNavigate: Function
        onPresetChange: Function
        onReleaseEvent: Function
        onRenderEvent: Function
        onResourceHeaderClick: Function
        onResourceHeaderContextmenu: Function
        onResourceHeaderDblclick: Function
        onScheduleClick: Function
        onScheduleContextMenu: Function
        onScheduleDblClick: Function
        onScheduleMenuBeforeShow: Function
        onScheduleMenuItem: Function
        onScheduleMenuShow: Function
        onScheduleMouseMove: Function
        onTimeAxisHeaderClick: Function
        onTimeAxisHeaderContextMenu: Function
        onTimeAxisHeaderContextMenuBeforeShow: Function
        onTimeAxisHeaderContextMenuItem: Function
        onTimeAxisHeaderContextMenuShow: Function
        onTimeAxisHeaderDblClick: Function
    }

    export class SchedulerBase extends TimelineBase implements EventNavigation, EventSelection, SchedulerDom, SchedulerDomEvents, SchedulerEventRendering, SchedulerRegions, SchedulerScroll, SchedulerState, SchedulerStores, TimelineDateMapper, TimelineDomEvents, TimelineEventRendering, TimelineScroll, TimelineViewPresets, TimelineZoomable, CrudManagerView, ProjectConsumer {
        static eventColors: string[]
        static eventStyles: string[]
        allowDropOnEventBar: boolean
        assignmentStore: SchedulerAssignmentStore
        assignments: SchedulerAssignmentModel[]|object[]|Partial<SchedulerAssignmentModelConfig>[]
        barMargin: number
        crudManager: CrudManager
        dependencies: SchedulerDependencyModel[]|object[]|Partial<SchedulerDependencyModelConfig>[]
        dependencyStore: SchedulerDependencyStore
        displayDateFormat: string
        editRecurrenceButton: RecurrenceLegendButton
        eventLayout: string
        eventStore: SchedulerEventStore
        events: SchedulerEventModel[]|object[]|Partial<SchedulerEventModelConfig>[]
        fillTicks: string
        isEngineReady: boolean
        localeManager: typeof LocaleManager
        maxZoomLevel: number
        milestoneAlign: string
        minZoomLevel: number
        mode: string
        presets: PresetStore|object[]|Partial<PresetStoreConfig>[]
        project: SchedulerProjectModel
        readOnly: boolean
        recurrenceCombo: RecurrenceCombo
        resourceColumnWidth: number
        resourceColumns: ResourceHeader
        resourceMargin: number
        resourceStore: SchedulerResourceStore
        resourceTimeRangeStore: ResourceTimeRangeStore|object|Partial<ResourceTimeRangeStoreConfig>
        resourceTimeRanges: ResourceTimeRangeModel[]|object[]|Partial<ResourceTimeRangeModelConfig>[]
        resources: SchedulerResourceModel[]|object[]|Partial<SchedulerResourceModelConfig>[]
        scrollLeft: number
        scrollTop: number
        selectedAssignments: SchedulerAssignmentModel[]
        selectedEvents: SchedulerEventModel[]
        snap: boolean
        state: object
        tickSize: number
        timeRangeStore: Store|object|Partial<StoreConfig>
        timeRanges: TimeSpan[]|object[]|Partial<TimeSpanConfig>[]
        timeResolution: object|number
        useInitialAnimation: boolean|string
        viewPreset: ViewPreset|string
        viewportCenterDate: Date
        visibleResources: object
        zoomLevel: number
        features: SchedulerBaseFeaturesType
        onAfterDependencyCreateDrop: Function
        onAfterDependencySave: Function
        onAfterDragCreate: Function
        onAfterEventDrop: Function
        onAfterEventSave: Function
        onAssignmentSelectionChange: Function
        onBeforeAssignmentDelete: Function
        onBeforeDependencyAdd: Function
        onBeforeDependencyCreateDrag: Function
        onBeforeDependencyCreateFinalize: Function
        onBeforeDependencyDelete: Function
        onBeforeDependencyEdit: Function
        onBeforeDependencyEditShow: Function
        onBeforeDependencySave: Function
        onBeforeDestroy: Function
        onBeforeDragCreate: Function
        onBeforeDragCreateFinalize: Function
        onBeforeEventAdd: Function
        onBeforeEventDelete: Function
        onBeforeEventDrag: Function
        onBeforeEventDropFinalize: Function
        onBeforeEventEdit: Function
        onBeforeEventEditShow: Function
        onBeforeEventResize: Function
        onBeforeEventResizeFinalize: Function
        onBeforeEventSave: Function
        onBeforeExport: Function
        onBeforePresetChange: Function
        onCatchAll: Function
        onContextMenuItem: Function
        onContextMenuToggleItem: Function
        onDataChange: Function
        onDependencyClick: Function
        onDependencyCreateDragStart: Function
        onDependencyCreateDrop: Function
        onDependencyDblClick: Function
        onDependencyMouseOut: Function
        onDependencyMouseOver: Function
        onDependencyValidationComplete: Function
        onDependencyValidationStart: Function
        onDestroy: Function
        onDragCreateEnd: Function
        onDragCreateStart: Function
        onEventClick: Function
        onEventContextMenu: Function
        onEventDblClick: Function
        onEventDrag: Function
        onEventDragAbort: Function
        onEventDragStart: Function
        onEventDrop: Function
        onEventEditBeforeSetRecord: Function
        onEventKeyDown: Function
        onEventKeyUp: Function
        onEventMenuBeforeShow: Function
        onEventMenuItem: Function
        onEventMenuShow: Function
        onEventMouseDown: Function
        onEventMouseOut: Function
        onEventMouseOver: Function
        onEventMouseUp: Function
        onEventPartialResize: Function
        onEventResizeEnd: Function
        onEventResizeStart: Function
        onEventSelectionChange: Function
        onExport: Function
        onHeaderMenuBeforeShow: Function
        onHeaderMenuItem: Function
        onHeaderMenuShow: Function
        onHeaderMenuToggleItem: Function
        onNavigate: Function
        onPresetChange: Function
        onReleaseEvent: Function
        onRenderEvent: Function
        onResourceHeaderClick: Function
        onResourceHeaderContextmenu: Function
        onResourceHeaderDblclick: Function
        onScheduleClick: Function
        onScheduleContextMenu: Function
        onScheduleDblClick: Function
        onScheduleMenuBeforeShow: Function
        onScheduleMenuItem: Function
        onScheduleMenuShow: Function
        onScheduleMouseMove: Function
        onTimeAxisHeaderClick: Function
        onTimeAxisHeaderContextMenu: Function
        onTimeAxisHeaderContextMenuBeforeShow: Function
        onTimeAxisHeaderContextMenuItem: Function
        onTimeAxisHeaderContextMenuShow: Function
        onTimeAxisHeaderDblClick: Function
        constructor(config?: Partial<SchedulerBaseConfig>);
        static optionalL(text: string, templateData?: object): string;
        L(text: string, templateData?: object): string;
        abort(): void;
        addListener(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        applyStartEndParameters(): void;
        clearEventSelection(): void;
        deselect(eventOrAssignment: SchedulerEventModel|SchedulerAssignmentModel): void;
        deselectAssignment(assignment: SchedulerAssignmentModel): void;
        deselectAssignments(assignments: SchedulerAssignmentModel[]): void;
        deselectEvent(event: SchedulerEventModel): void;
        deselectEvents(events: SchedulerEventModel[]): void;
        editEvent(eventRecord: SchedulerEventModel, resourceRecord?: SchedulerResourceModel): void;
        getCoordinateFromDate(date: Date|number, options?: boolean|object): number;
        getDateFromCoordinate(coordinate: number, roundingMethod?: string, local?: boolean, allowOutOfRange?: boolean): Date;
        getDateFromDomEvent(e: Event, roundingMethod?: string, allowOutOfRange?: boolean): Date;
        getDateFromXY(xy: any[], roundingMethod?: string, local?: boolean, allowOutOfRange?: boolean): Date;
        getElementFromAssignmentRecord(assignmentRecord: SchedulerAssignmentModel): HTMLElement;
        getElementFromEventRecord(eventRecord: SchedulerEventModel, resourceRecord: SchedulerResourceModel): HTMLElement;
        getElementsFromEventRecord(eventRecord: SchedulerEventModel, resourceRecord?: SchedulerResourceModel): HTMLElement[];
        getMilestoneLabelWidth(eventRecord: SchedulerEventModel): number;
        getResourceEventBox(eventRecord: SchedulerEventModel, resourceRecord: SchedulerResourceModel, includeOutside?: boolean): Rectangle;
        getResourceRegion(resourceRecord: SchedulerResourceModel, startDate: Date, endDate: Date): Rectangle;
        getScheduleRegion(resourceRecord: SchedulerResourceModel, eventRecord: SchedulerEventModel): Rectangle;
        getStartEndDatesFromRectangle(rect: Rectangle, roundingMethod: string, duration: number): object;
        getTimeSpanDistance(startDate: Date, endDate: Date): number;
        hasListener(eventName: string): boolean;
        hideTerminals(eventElement: HTMLElement): void;
        isAssignmentSelected(assignment: SchedulerAssignmentModel): boolean;
        isDateRangeAvailable(start: Date, end: Date, excludeEvent: SchedulerEventModel|null, resource: SchedulerResourceModel): boolean;
        isEventSelected(event: SchedulerEventModel): boolean;
        on(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        onEventCreated(eventRecord: SchedulerEventModel): void;
        onEventDataGenerated(eventData: object): void;
        relayAll(through: Events, prefix: string, transformCase?: boolean): void;
        removeAllListeners(): void;
        removeListener(config: object, thisObj: object): void;
        repaintEventsForResource(resourceRecord: SchedulerResourceModel): void;
        resolveAssignmentRecord(element: HTMLElement): SchedulerAssignmentModel;
        resolveDependencyRecord(element: HTMLElement): SchedulerDependencyModel;
        resolveEventRecord(element: HTMLElement): SchedulerEventModel;
        resolveResourceRecord(elementOrEvent: HTMLElement|Event, xy?: number[]): SchedulerResourceModel;
        restartInitialAnimation(initialAnimation: boolean|string): void;
        resumeEvents(): void;
        resumeRefresh(trigger: boolean): Promise<any>;
        scrollAssignmentIntoView(assignmentRecord: SchedulerAssignmentModel, index: number, options?: object): Promise<any>;
        scrollEventIntoView(eventRecord: SchedulerEventModel, options?: object): Promise<any>;
        scrollHorizontallyTo(x: number, options?: object|boolean): Promise<any>;
        scrollResourceEventIntoView(resourceRecord: SchedulerResourceModel, eventRecord: SchedulerEventModel, index: number, options?: object): Promise<any>;
        scrollResourceIntoView(resourceRecord: SchedulerResourceModel, options?: object): Promise<any>;
        scrollTo(x: number, options?: object|boolean): Promise<any>;
        scrollToDate(date: Date, options?: object): Promise<any>;
        scrollToNow(options?: object): Promise<any>;
        scrollVerticallyTo(y: number, options?: object|boolean): Promise<any>;
        select(eventOrAssignment: SchedulerEventModel|SchedulerAssignmentModel, preserveSelection?: boolean): void;
        selectAssignment(assignment: SchedulerAssignmentModel, preserveSelection?: boolean): void;
        selectAssignments(assignments: SchedulerAssignmentModel[]): void;
        selectEvent(event: SchedulerEventModel, preserveSelection?: boolean): void;
        selectEvents(events: SchedulerEventModel[]): void;
        setTimeSpan(startDate: Date, endDate: Date): void;
        shift(amount: number, unit?: string): void;
        shiftNext(amount?: number): void;
        shiftPrevious(amount?: number): void;
        showContextMenu(event: Event, alignSpec?: object|HTMLElement): void;
        showTerminals(timeSpanRecord: TimeSpan, element: HTMLElement): void;
        suspendEvents(queue?: boolean): void;
        suspendRefresh(): void;
        trigger(eventName: string, param?: object): boolean|Promise<any>;
        un(config: object, thisObj?: object): void;
        updateLocalization(): void;
        updateProject(project: SchedulerProjectModel): void;
        whenProjectReady(callback: Function): void;
        zoomIn(levels?: number): number;
        zoomInFull(): number;
        zoomOut(levels?: number): number;
        zoomOutFull(): number;
        zoomTo(config: object|string|number): void;
        zoomToFit(options?: object): void;
        zoomToLevel(preset: number, options?: object): number;
        zoomToSpan(config: object): number;
    }

    type TimelineBaseFeaturesType = {
        cellEdit: GridCellEdit
        cellMenu: CellMenu
        cellTooltip: CellTooltip
        columnAutoWidth: ColumnAutoWidth
        columnDragToolbar: ColumnDragToolbar
        columnPicker: ColumnPicker
        columnReorder: ColumnReorder
        columnResize: ColumnResize
        contextMenu: ContextMenu
        excelExporter: GridExcelExporter
        filter: Filter
        filterBar: FilterBar
        group: Group
        groupSummary: GridGroupSummary
        headerMenu: HeaderMenu
        pdfExport: GridPdfExport
        quickFind: QuickFind
        regionResize: RegionResize
        rowCopyPaste: RowCopyPaste
        rowReorder: RowReorder
        search: Search
        sort: Sort
        stickyCells: StickyCells
        stripe: Stripe
        summary: GridSummary
        tree: Tree
    }

    type TimelineBaseFeaturesConfigType = {
        cellEdit: string|boolean|Partial<GridCellEditConfig>
        cellMenu: string|boolean|Partial<CellMenuConfig>
        cellTooltip: string|boolean|Partial<CellTooltipConfig>
        columnAutoWidth: string|boolean|Partial<ColumnAutoWidthConfig>
        columnDragToolbar: string|boolean|Partial<ColumnDragToolbarConfig>
        columnPicker: string|boolean|Partial<ColumnPickerConfig>
        columnReorder: string|boolean|Partial<ColumnReorderConfig>
        columnResize: string|boolean|Partial<ColumnResizeConfig>
        contextMenu: string|boolean|Partial<ContextMenuConfig>
        excelExporter: string|boolean|Partial<GridExcelExporterConfig>
        filter: string|boolean|Partial<FilterConfig>
        filterBar: string|boolean|Partial<FilterBarConfig>
        group: string|boolean|Partial<GroupConfig>
        groupSummary: string|boolean|Partial<GridGroupSummaryConfig>
        headerMenu: string|boolean|Partial<HeaderMenuConfig>
        pdfExport: string|boolean|Partial<GridPdfExportConfig>
        quickFind: string|boolean|Partial<QuickFindConfig>
        regionResize: string|boolean|Partial<RegionResizeConfig>
        rowCopyPaste: string|boolean|Partial<RowCopyPasteConfig>
        rowReorder: string|boolean|Partial<RowReorderConfig>
        search: string|boolean|Partial<SearchConfig>
        sort: string|boolean|Partial<SortConfig>
        stickyCells: string|boolean|Partial<StickyCellsConfig>
        stripe: string|boolean|Partial<StripeConfig>
        summary: string|boolean|Partial<GridSummaryConfig>
        tree: string|boolean|Partial<TreeConfig>
    }

    type TimelineBaseConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        animateRemovingRows: boolean
        appendTo: HTMLElement|string
        autoAdjustTimeAxis: boolean
        autoHeight: boolean
        barMargin: number
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        bufferCoef: number
        bufferThreshold: number
        centered: boolean
        cls: string|object
        columnLines: boolean
        columns: object[]|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        contextMenuTriggerEvent: string
        data: object[]
        dataset: object
        defaultBindProperty: string
        defaultRegion: string
        defaults: object
        destroyStore: boolean
        disableGridRowModelWarning: boolean
        disabled: boolean
        displayDateFormat: string
        dock: string
        draggable: boolean|object
        durationDisplayPrecision: number|boolean
        emptyText: string
        enableEventAnimations: boolean
        enableRecurringEvents: boolean
        enableSticky: boolean
        enableTextSelection: boolean
        enableUndoRedoKeys: boolean
        endDate: Date|string
        eventColor: string
        eventStyle: string
        features: Partial<TimelineBaseFeaturesConfigType>
        fillLastColumn: boolean
        fixedRowHeight: boolean
        flex: number|string
        floating: boolean
        footer: object|string
        forceFit: boolean
        fullRowRefresh: boolean
        getDateConstraints: Function
        getRowHeight: Function
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideHeaders: boolean
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        infiniteScroll: boolean
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        loadMask: string|object|null
        loadMaskDefaults: object|Mask|Partial<MaskConfig>
        loadMaskError: object|Mask|Partial<MaskConfig>
        localeClass: Base
        localizableProperties: string[]
        longPressTime: number
        managedEventSizing: boolean
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maxZoomLevel: number
        minHeight: string|number
        minWidth: string|number
        minZoomLevel: number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        partner: TimelineBase
        plugins: Function[]
        positioned: boolean
        preserveFocusOnDatasetChange: boolean
        preserveScrollOnDatasetChange: boolean
        presets: object[]
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        resizeToFitIncludesHeader: boolean
        responsiveLevels: object
        ripple: boolean|object
        rootElement: ShadowRoot
        rowHeight: number
        scrollAction: string
        scrollManager: object|ScrollManager|Partial<ScrollManagerConfig>
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        scrollerClass: Scroller
        selectionMode: object
        showAnimation: boolean|object
        showDirty: boolean
        showRemoveRowInContextMenu: boolean
        snap: boolean
        snapRelativeToEventStartDate: boolean
        startDate: Date|string
        stickyHeaders: boolean
        store: Store|object|Partial<StoreConfig>
        strips: object
        style: string
        subGridConfigs: object
        suppressFit: boolean
        syncMask: string|object|null
        tab: boolean|object
        tag: string
        tbar: object[]|object
        textAlign: string
        textContent: boolean
        tickSize: number
        timeAxis: object|TimeAxis|Partial<TimeAxisConfig>
        title: string
        tools: object
        tooltip: string|object
        transitionDuration: number
        trapFocus: boolean
        viewPreset: string|object
        visibleDate: Date|object
        visibleZoomFactor: number
        weekStartDay: number
        weight: number
        width: string|number
        workingTime: object
        x: number
        y: number
        zoomKeepsOriginalTimespan: boolean
        zoomOnMouseWheel: boolean
        zoomOnTimeAxisDoubleClick: boolean
        onBeforePresetChange: Function
        onPresetChange: Function
        onTimeAxisChange: Function
        onTimeAxisHeaderClick: Function
        onTimeAxisHeaderContextMenu: Function
        onTimeAxisHeaderDblClick: Function
        onTimelineViewportResize: Function
    }

    export abstract class TimelineBase extends Grid implements TimelineDateMapper, TimelineDomEvents, TimelineEventRendering, TimelineScroll, TimelineViewPresets, TimelineZoomable, RecurringEvents {
        static eventColors: string[]
        static eventStyles: string[]
        barMargin: number
        displayDateFormat: string
        endDate: Date
        hasVisibleEvents: boolean
        maxZoomLevel: number
        minZoomLevel: number
        partners: TimelineBase
        presets: PresetStore|object[]|Partial<PresetStoreConfig>[]
        scrollLeft: number
        scrollTop: number
        snap: boolean
        startDate: Date
        tickSize: number
        timeAxis: TimeAxis
        timeAxisSubGrid: SubGrid
        timeAxisSubGridElement: HTMLElement
        timeAxisViewModel: TimeAxisViewModel
        timeResolution: object|number
        viewPreset: ViewPreset|string
        viewportCenterDate: Date
        visibleDateRange: object
        workingTime: object
        zoomLevel: number
        features: TimelineBaseFeaturesType
        onBeforePresetChange: Function
        onPresetChange: Function
        onTimeAxisChange: Function
        onTimeAxisHeaderClick: Function
        onTimeAxisHeaderContextMenu: Function
        onTimeAxisHeaderDblClick: Function
        onTimelineViewportResize: Function
        constructor(config?: Partial<TimelineBaseConfig>);
        addPartner(otherTimeline: TimelineBase): void;
        formatDuration(The: number, nbrDecimals?: number): number;
        getCoordinateFromDate(date: Date|number, options?: boolean|object): number;
        getDateFromCoordinate(coordinate: number, roundingMethod?: string, local?: boolean, allowOutOfRange?: boolean): Date;
        getDateFromDomEvent(e: Event, roundingMethod?: string, allowOutOfRange?: boolean): Date;
        getDateFromXY(xy: any[], roundingMethod?: string, local?: boolean, allowOutOfRange?: boolean): Date;
        getForegroundDomConfigs(configs: any[]): void;
        getHeaderDomConfigs(configs: any[]): void;
        getOccurrencesFor(recurringEvent: TimeSpan): TimeSpan[];
        getStartEndDatesFromRectangle(rect: Rectangle, roundingMethod: string, duration: number): object;
        getTimeSpanDistance(startDate: Date, endDate: Date): number;
        getVisibleDateRange(): object;
        isPartneredWith(partner: TimelineBase): boolean;
        preserveViewCenter(fn: Function, thisObj: object, args: any): void;
        refreshWithTransition(): void;
        removePartner(otherTimeline: TimelineBase): void;
        scrollHorizontallyTo(x: number, options?: object|boolean): Promise<any>;
        scrollTo(x: number, options?: object|boolean): Promise<any>;
        scrollToDate(date: Date, options?: object): Promise<any>;
        scrollToNow(options?: object): Promise<any>;
        scrollVerticallyTo(y: number, options?: object|boolean): Promise<any>;
        setEndDate(date: Date, keepDuration?: boolean): void;
        setStartDate(date: Date, keepDuration?: boolean): void;
        setTimeSpan(startDate: Date, endDate: Date): void;
        shift(amount: number, unit?: string): void;
        shiftNext(amount?: number): void;
        shiftPrevious(amount?: number): void;
        zoomIn(levels?: number): number;
        zoomInFull(): number;
        zoomOut(levels?: number): number;
        zoomOutFull(): number;
        zoomTo(config: object|string|number): void;
        zoomToFit(options?: object): void;
        zoomToLevel(preset: number, options?: object): number;
        zoomToSpan(config: object): number;
    }

    type SchedulerExportDialogConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoSelectVisibleColumns: boolean
        autoShow: boolean
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        centered: boolean
        client: Grid
        closable: boolean
        closeAction: string
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hidePNGMultipageOption: boolean
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maximizable: boolean
        maximized: boolean
        minHeight: string|number
        minWidth: string|number
        modal: boolean
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showOnClick: boolean
        strips: object
        style: string
        tab: boolean|object
        tag: string
        tbar: object[]|object
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        trapFocus: boolean
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class SchedulerExportDialog extends ExportDialog {
        constructor(config?: Partial<SchedulerExportDialogConfig>);
    }

    type EventNavigationConfig = {
        enableDeleteKey: boolean
        onBeforeAssignmentDelete: Function
        onBeforeEventDelete: Function
        onNavigate: Function
    }

    export class EventNavigation {
        onBeforeAssignmentDelete: Function
        onBeforeEventDelete: Function
        onNavigate: Function
        constructor(config?: Partial<EventNavigationConfig>);
    }

    type EventSelectionConfig = {
        eventSelectionDisabled: boolean
        highlightPredecessors: boolean
        highlightSuccessors: boolean
        maintainSelectionOnDatasetChange: boolean
        multiEventSelect: boolean
        triggerSelectionChangeOnRemove: boolean
        onAssignmentSelectionChange: Function
        onEventSelectionChange: Function
    }

    export class EventSelection {
        selectedAssignments: SchedulerAssignmentModel[]
        selectedEvents: SchedulerEventModel[]
        onAssignmentSelectionChange: Function
        onEventSelectionChange: Function
        constructor(config?: Partial<EventSelectionConfig>);
        clearEventSelection(): void;
        deselect(eventOrAssignment: SchedulerEventModel|SchedulerAssignmentModel): void;
        deselectAssignment(assignment: SchedulerAssignmentModel): void;
        deselectAssignments(assignments: SchedulerAssignmentModel[]): void;
        deselectEvent(event: SchedulerEventModel): void;
        deselectEvents(events: SchedulerEventModel[]): void;
        isAssignmentSelected(assignment: SchedulerAssignmentModel): boolean;
        isEventSelected(event: SchedulerEventModel): boolean;
        select(eventOrAssignment: SchedulerEventModel|SchedulerAssignmentModel, preserveSelection?: boolean): void;
        selectAssignment(assignment: SchedulerAssignmentModel, preserveSelection?: boolean): void;
        selectAssignments(assignments: SchedulerAssignmentModel[]): void;
        selectEvent(event: SchedulerEventModel, preserveSelection?: boolean): void;
        selectEvents(events: SchedulerEventModel[]): void;
    }

    type RecurringEventsConfig = {
        enableRecurringEvents: boolean
    }

    export class RecurringEvents {
        constructor(config?: Partial<RecurringEventsConfig>);
        getOccurrencesFor(recurringEvent: TimeSpan): TimeSpan[];
    }

    export class SchedulerDom {
        getElementFromAssignmentRecord(assignmentRecord: SchedulerAssignmentModel): HTMLElement;
        getElementFromEventRecord(eventRecord: SchedulerEventModel, resourceRecord: SchedulerResourceModel): HTMLElement;
        getElementsFromEventRecord(eventRecord: SchedulerEventModel, resourceRecord?: SchedulerResourceModel): HTMLElement[];
        resolveAssignmentRecord(element: HTMLElement): SchedulerAssignmentModel;
        resolveEventRecord(element: HTMLElement): SchedulerEventModel;
        resolveResourceRecord(elementOrEvent: HTMLElement|Event, xy?: number[]): SchedulerResourceModel;
    }

    type SchedulerDomEventsConfig = {
        onEventClick: Function
        onEventContextMenu: Function
        onEventDblClick: Function
        onEventMouseDown: Function
        onEventMouseOut: Function
        onEventMouseOver: Function
        onEventMouseUp: Function
        onScheduleClick: Function
        onScheduleContextMenu: Function
        onScheduleDblClick: Function
        onScheduleMouseMove: Function
    }

    export class SchedulerDomEvents {
        onEventClick: Function
        onEventContextMenu: Function
        onEventDblClick: Function
        onEventMouseDown: Function
        onEventMouseOut: Function
        onEventMouseOver: Function
        onEventMouseUp: Function
        onScheduleClick: Function
        onScheduleContextMenu: Function
        onScheduleDblClick: Function
        onScheduleMouseMove: Function
    }

    type SchedulerEventRenderingConfig = {
        barMargin: number
        defaultResourceImageName: string
        eventBarTextField: string
        eventBodyTemplate: Function
        eventLayout: string
        eventRenderer: Function
        eventRendererThisObj: object
        fillTicks: boolean
        horizontalEventSorterFn: Function
        milestoneAlign: string
        milestoneCharWidth: number
        milestoneLayoutMode: string
        milestoneTextPosition: string
        resourceColumns: object
        resourceImageExtension: string
        resourceImagePath: string
        resourceMargin: number
        useInitialAnimation: boolean|string
    }

    export class SchedulerEventRendering {
        eventLayout: string
        fillTicks: string
        milestoneAlign: string
        resourceColumnWidth: number
        resourceColumns: ResourceHeader
        resourceMargin: number
        useInitialAnimation: boolean|string
        constructor(config?: Partial<SchedulerEventRenderingConfig>);
        getMilestoneLabelWidth(eventRecord: SchedulerEventModel): number;
        onEventDataGenerated(eventData: object): void;
        repaintEventsForResource(resourceRecord: SchedulerResourceModel): void;
        restartInitialAnimation(initialAnimation: boolean|string): void;
    }

    export class SchedulerRegions {
        getResourceEventBox(eventRecord: SchedulerEventModel, resourceRecord: SchedulerResourceModel, includeOutside?: boolean): Rectangle;
        getResourceRegion(resourceRecord: SchedulerResourceModel, startDate: Date, endDate: Date): Rectangle;
        getScheduleRegion(resourceRecord: SchedulerResourceModel, eventRecord: SchedulerEventModel): Rectangle;
    }

    export class SchedulerScroll {
        scrollAssignmentIntoView(assignmentRecord: SchedulerAssignmentModel, index: number, options?: object): Promise<any>;
        scrollEventIntoView(eventRecord: SchedulerEventModel, options?: object): Promise<any>;
        scrollResourceEventIntoView(resourceRecord: SchedulerResourceModel, eventRecord: SchedulerEventModel, index: number, options?: object): Promise<any>;
        scrollResourceIntoView(resourceRecord: SchedulerResourceModel, options?: object): Promise<any>;
    }

    export class SchedulerState {
        state: object
    }

    type SchedulerStoresConfig = {
        assignmentStore: SchedulerAssignmentStore|object|Partial<SchedulerAssignmentStoreConfig>
        assignments: SchedulerAssignmentModel[]|object[]|Partial<SchedulerAssignmentModelConfig>[]
        crudManager: object|CrudManager|Partial<CrudManagerConfig>
        crudManagerClass: CrudManager
        dependencies: SchedulerDependencyModel[]|object[]|Partial<SchedulerDependencyModelConfig>[]
        dependencyStore: SchedulerDependencyStore|object|Partial<SchedulerDependencyStoreConfig>
        destroyStores: boolean
        endParamName: string
        eventStore: SchedulerEventStore|object|Partial<SchedulerEventStoreConfig>
        events: SchedulerEventModel[]|object[]|Partial<SchedulerEventModelConfig>[]
        passStartEndParameters: boolean
        project: SchedulerProjectModel|object|Partial<SchedulerProjectModelConfig>
        removeUnassignedEvent: boolean
        resourceStore: SchedulerResourceStore|object|Partial<SchedulerResourceStoreConfig>
        resourceTimeRangeStore: ResourceTimeRangeStore|object|Partial<ResourceTimeRangeStoreConfig>
        resourceTimeRanges: ResourceTimeRangeModel[]|object[]|Partial<ResourceTimeRangeModelConfig>[]
        resources: SchedulerResourceModel[]|object[]|Partial<SchedulerResourceModelConfig>[]
        startParamName: string
        timeRangeStore: Store|object|Partial<StoreConfig>
        timeRanges: TimeSpan[]|object[]|Partial<TimeSpanConfig>[]
    }

    export class SchedulerStores extends ProjectConsumer {
        assignmentStore: SchedulerAssignmentStore
        assignments: SchedulerAssignmentModel[]|object[]|Partial<SchedulerAssignmentModelConfig>[]
        crudManager: CrudManager
        dependencies: SchedulerDependencyModel[]|object[]|Partial<SchedulerDependencyModelConfig>[]
        dependencyStore: SchedulerDependencyStore
        eventStore: SchedulerEventStore
        events: SchedulerEventModel[]|object[]|Partial<SchedulerEventModelConfig>[]
        resourceStore: SchedulerResourceStore
        resourceTimeRangeStore: ResourceTimeRangeStore|object|Partial<ResourceTimeRangeStoreConfig>
        resourceTimeRanges: ResourceTimeRangeModel[]|object[]|Partial<ResourceTimeRangeModelConfig>[]
        resources: SchedulerResourceModel[]|object[]|Partial<SchedulerResourceModelConfig>[]
        timeRangeStore: Store|object|Partial<StoreConfig>
        timeRanges: TimeSpan[]|object[]|Partial<TimeSpanConfig>[]
        constructor(config?: Partial<SchedulerStoresConfig>);
        applyStartEndParameters(): void;
    }

    export class TimelineDateMapper {
        displayDateFormat: string
        snap: boolean
        timeResolution: object|number
        viewportCenterDate: Date
        getCoordinateFromDate(date: Date|number, options?: boolean|object): number;
        getDateFromCoordinate(coordinate: number, roundingMethod?: string, local?: boolean, allowOutOfRange?: boolean): Date;
        getDateFromDomEvent(e: Event, roundingMethod?: string, allowOutOfRange?: boolean): Date;
        getDateFromXY(xy: any[], roundingMethod?: string, local?: boolean, allowOutOfRange?: boolean): Date;
        getStartEndDatesFromRectangle(rect: Rectangle, roundingMethod: string, duration: number): object;
        getTimeSpanDistance(startDate: Date, endDate: Date): number;
    }

    type TimelineDomEventsConfig = {
        onTimeAxisHeaderClick: Function
        onTimeAxisHeaderContextMenu: Function
        onTimeAxisHeaderDblClick: Function
    }

    export class TimelineDomEvents {
        onTimeAxisHeaderClick: Function
        onTimeAxisHeaderContextMenu: Function
        onTimeAxisHeaderDblClick: Function
    }

    type TimelineEventRenderingConfig = {
        barMargin: number
        eventColor: string
        eventStyle: string
        managedEventSizing: boolean
        tickSize: number
    }

    export class TimelineEventRendering {
        static eventColors: string[]
        static eventStyles: string[]
        barMargin: number
        tickSize: number
        constructor(config?: Partial<TimelineEventRenderingConfig>);
    }

    type TimelineScrollConfig = {
        bufferCoef: number
        bufferThreshold: number
        infiniteScroll: boolean
    }

    export class TimelineScroll {
        scrollLeft: number
        scrollTop: number
        constructor(config?: Partial<TimelineScrollConfig>);
        scrollHorizontallyTo(x: number, options?: object|boolean): Promise<any>;
        scrollTo(x: number, options?: object|boolean): Promise<any>;
        scrollToDate(date: Date, options?: object): Promise<any>;
        scrollToNow(options?: object): Promise<any>;
        scrollVerticallyTo(y: number, options?: object|boolean): Promise<any>;
    }

    type TimelineViewPresetsConfig = {
        displayDateFormat: string
        presets: object[]
        viewPreset: string|object
        onBeforePresetChange: Function
        onPresetChange: Function
    }

    export class TimelineViewPresets {
        presets: PresetStore|object[]|Partial<PresetStoreConfig>[]
        viewPreset: ViewPreset|string
        onBeforePresetChange: Function
        onPresetChange: Function
        constructor(config?: Partial<TimelineViewPresetsConfig>);
    }

    type TimelineZoomableConfig = {
        maxZoomLevel: number
        minZoomLevel: number
        visibleZoomFactor: number
        zoomKeepsOriginalTimespan: boolean
        zoomOnMouseWheel: boolean
        zoomOnTimeAxisDoubleClick: boolean
    }

    export class TimelineZoomable {
        maxZoomLevel: number
        minZoomLevel: number
        zoomLevel: number
        constructor(config?: Partial<TimelineZoomableConfig>);
        setTimeSpan(startDate: Date, endDate: Date): void;
        shift(amount: number, unit?: string): void;
        shiftNext(amount?: number): void;
        shiftPrevious(amount?: number): void;
        zoomIn(levels?: number): number;
        zoomInFull(): number;
        zoomOut(levels?: number): number;
        zoomOutFull(): number;
        zoomTo(config: object|string|number): void;
        zoomToFit(options?: object): void;
        zoomToLevel(preset: number, options?: object): number;
        zoomToSpan(config: object): number;
    }

    type TimeAxisViewModelConfig = {
        bubbleEvents: object
        listeners: object
        onReconfigure: Function
        onUpdate: Function
    }

    export class TimeAxisViewModel extends Events {
        onReconfigure: Function
        onUpdate: Function
        constructor(config?: Partial<TimeAxisViewModelConfig>);
        getDateFromPosition(position: number, roundingMethod?: string, allowOutOfRange?: boolean): Date;
        getDistanceBetweenDates(start: Date, end: Date): number;
        getDistanceForDuration(durationMS: number): number;
        getPositionFromDate(date: Date): number;
    }

    type RecurrenceConfirmationPopupConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoShow: boolean
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maximizable: boolean
        maximized: boolean
        minHeight: string|number
        minWidth: string|number
        modal: boolean
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showOnClick: boolean
        strips: object
        style: string
        tab: boolean|object
        tag: string
        tbar: object[]|object
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        trapFocus: boolean
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class RecurrenceConfirmationPopup extends Popup {
        cancelButton: Button
        changeMultipleButton: Button
        changeSingleButton: Button
        constructor(config?: Partial<RecurrenceConfirmationPopupConfig>);
        confirm(config: object): void;
        onCancelButtonClick(): void;
        onChangeMultipleButtonClick(): void;
        onChangeSingleButtonClick(): void;
        processMultipleRecords(): void;
        processSingleRecord(): void;
    }

    type RecurrenceEditorConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoShow: boolean
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maximizable: boolean
        maximized: boolean
        minHeight: string|number
        minWidth: string|number
        modal: boolean
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showOnClick: boolean
        strips: object
        style: string
        tab: boolean|object
        tag: string
        tbar: object[]|object
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        trapFocus: boolean
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class RecurrenceEditor extends Popup {
        constructor(config?: Partial<RecurrenceEditorConfig>);
        syncEventRecord(): void;
    }

    type RecurrenceLegendButtonConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        badge: string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        color: string
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        href: string
        html: string
        htmlCls: string|object
        icon: string
        iconAlign: string
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        menu: object|object[]|Widget|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        owner: Widget
        positioned: boolean
        pressed: boolean
        pressedIcon: string
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        target: string
        text: string
        textAlign: string
        title: string
        toggleGroup: string
        toggleable: boolean
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class RecurrenceLegendButton extends Button {
        recurrence: RecurrenceModel
        constructor(config?: Partial<RecurrenceLegendButtonConfig>);
    }

    type RecurrenceComboConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoComplete: string
        autoExpand: boolean
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        caseSensitive: boolean
        centered: boolean
        chipView: object
        clearTextOnPickerHide: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        displayField: string
        displayValueRenderer: Function
        dock: string
        draggable: boolean|object
        editable: boolean
        emptyText: string
        encodeFilterParams: Function
        filterOnEnter: boolean
        filterOperator: string
        filterParamName: string
        filterSelected: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hidePickerOnSelect: boolean
        hideTrigger: boolean
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        items: object[]|string[]|object
        keyStrokeChangeDelay: number
        keyStrokeFilterDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listCls: string
        listItemTpl: Function
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        minChars: number
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        multiSelect: boolean
        name: string
        overlayAnchor: boolean
        owner: Widget
        picker: object
        pickerAlignElement: string
        pickerWidth: number
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        primaryFilter: object
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        store: Store
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggerAction: string
        triggers: object
        validateFilter: boolean
        value: string|number[]|string[]
        valueField: string
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class RecurrenceCombo extends RecurrenceFrequencyCombo {
        constructor(config?: Partial<RecurrenceComboConfig>);
    }

    type RecurrenceDaysButtonGroupConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string
        color: string
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object[]|Button[]|Partial<ButtonConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        textContent: boolean
        title: string
        toggleGroup: boolean
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class RecurrenceDaysButtonGroup extends ButtonGroup {
        constructor(config?: Partial<RecurrenceDaysButtonGroupConfig>);
    }

    type RecurrenceDaysComboConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoComplete: string
        autoExpand: boolean
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        caseSensitive: boolean
        centered: boolean
        chipView: object
        clearTextOnPickerHide: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        displayField: string
        displayValueRenderer: Function
        dock: string
        draggable: boolean|object
        editable: boolean
        emptyText: string
        encodeFilterParams: Function
        filterOnEnter: boolean
        filterOperator: string
        filterParamName: string
        filterSelected: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hidePickerOnSelect: boolean
        hideTrigger: boolean
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        items: object[]|string[]|object
        keyStrokeChangeDelay: number
        keyStrokeFilterDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listCls: string
        listItemTpl: Function
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        minChars: number
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        multiSelect: boolean
        name: string
        overlayAnchor: boolean
        owner: Widget
        picker: object
        pickerAlignElement: string
        pickerWidth: number
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        primaryFilter: object
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        store: Store
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggerAction: string
        triggers: object
        validateFilter: boolean
        value: string|number[]|string[]
        valueField: string
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class RecurrenceDaysCombo extends Combo {
        constructor(config?: Partial<RecurrenceDaysComboConfig>);
    }

    type RecurrenceFrequencyComboConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoComplete: string
        autoExpand: boolean
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        caseSensitive: boolean
        centered: boolean
        chipView: object
        clearTextOnPickerHide: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        displayField: string
        displayValueRenderer: Function
        dock: string
        draggable: boolean|object
        editable: boolean
        emptyText: string
        encodeFilterParams: Function
        filterOnEnter: boolean
        filterOperator: string
        filterParamName: string
        filterSelected: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hidePickerOnSelect: boolean
        hideTrigger: boolean
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        items: object[]|string[]|object
        keyStrokeChangeDelay: number
        keyStrokeFilterDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listCls: string
        listItemTpl: Function
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        minChars: number
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        multiSelect: boolean
        name: string
        overlayAnchor: boolean
        owner: Widget
        picker: object
        pickerAlignElement: string
        pickerWidth: number
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        primaryFilter: object
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        store: Store
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggerAction: string
        triggers: object
        validateFilter: boolean
        value: string|number[]|string[]
        valueField: string
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class RecurrenceFrequencyCombo extends Combo {
        constructor(config?: Partial<RecurrenceFrequencyComboConfig>);
    }

    type RecurrencePositionsComboConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoComplete: string
        autoExpand: boolean
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        caseSensitive: boolean
        centered: boolean
        chipView: object
        clearTextOnPickerHide: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        displayField: string
        displayValueRenderer: Function
        dock: string
        draggable: boolean|object
        editable: boolean
        emptyText: string
        encodeFilterParams: Function
        filterOnEnter: boolean
        filterOperator: string
        filterParamName: string
        filterSelected: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hidePickerOnSelect: boolean
        hideTrigger: boolean
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        items: object[]|string[]|object
        keyStrokeChangeDelay: number
        keyStrokeFilterDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listCls: string
        listItemTpl: Function
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        minChars: number
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        multiSelect: boolean
        name: string
        overlayAnchor: boolean
        owner: Widget
        picker: object
        pickerAlignElement: string
        pickerWidth: number
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        primaryFilter: object
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        store: Store
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggerAction: string
        triggers: object
        validateFilter: boolean
        value: string|number[]|string[]
        valueField: string
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class RecurrencePositionsCombo extends Combo {
        constructor(config?: Partial<RecurrencePositionsComboConfig>);
    }

    type RecurrenceStopConditionComboConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoComplete: string
        autoExpand: boolean
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        caseSensitive: boolean
        centered: boolean
        chipView: object
        clearTextOnPickerHide: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        displayField: string
        displayValueRenderer: Function
        dock: string
        draggable: boolean|object
        editable: boolean
        emptyText: string
        encodeFilterParams: Function
        filterOnEnter: boolean
        filterOperator: string
        filterParamName: string
        filterSelected: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hidePickerOnSelect: boolean
        hideTrigger: boolean
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        items: object[]|string[]|object
        keyStrokeChangeDelay: number
        keyStrokeFilterDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listCls: string
        listItemTpl: Function
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        minChars: number
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        multiSelect: boolean
        name: string
        overlayAnchor: boolean
        owner: Widget
        picker: object
        pickerAlignElement: string
        pickerWidth: number
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        primaryFilter: object
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        store: Store
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggerAction: string
        triggers: object
        validateFilter: boolean
        value: string|number[]|string[]
        valueField: string
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class RecurrenceStopConditionCombo extends Combo {
        constructor(config?: Partial<RecurrenceStopConditionComboConfig>);
    }

    type ResourceComboConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoComplete: string
        autoExpand: boolean
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        caseSensitive: boolean
        centered: boolean
        chipView: object
        clearTextOnPickerHide: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        displayField: string
        displayValueRenderer: Function
        dock: string
        draggable: boolean|object
        editable: boolean
        emptyText: string
        encodeFilterParams: Function
        filterOnEnter: boolean
        filterOperator: string
        filterParamName: string
        filterSelected: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hidePickerOnSelect: boolean
        hideTrigger: boolean
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        items: object[]|string[]|object
        keyStrokeChangeDelay: number
        keyStrokeFilterDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listCls: string
        listItemTpl: Function
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        minChars: number
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        multiSelect: boolean
        name: string
        overlayAnchor: boolean
        owner: Widget
        picker: object
        pickerAlignElement: string
        pickerWidth: number
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        primaryFilter: object
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        store: Store
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggerAction: string
        triggers: object
        validateFilter: boolean
        value: string|number[]|string[]
        valueField: string
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class ResourceCombo extends Combo {
        constructor(config?: Partial<ResourceComboConfig>);
    }

    type ResourceFilterConfig = {
        activateOnMouseover: boolean
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        allowGroupSelect: boolean
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        eventStore: SchedulerEventStore
        flex: number|string
        floating: boolean
        groupHeaderTpl: Function
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemTpl: Function
        items: object[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        multiSelect: boolean
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        selectAllItem: boolean|string
        selected: Collection|object|Partial<CollectionConfig>
        showAnimation: boolean|object
        store: object|Store|Partial<StoreConfig>
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        title: string
        toggleAllIfCtrlPressed: boolean
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class ResourceFilter extends List {
        constructor(config?: Partial<ResourceFilterConfig>);
    }

    type UndoRedoConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        color: string
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        project: SchedulerProjectModel
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scheduler: Widget|string
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showZeroActionBadge: boolean
        style: string
        tab: boolean|object
        tag: string
        text: boolean
        textAlign: string
        textContent: boolean
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class UndoRedo extends UndoRedoBase {
        constructor(config?: Partial<UndoRedoConfig>);
    }

    type DurationColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        decimalPrecision: number|boolean
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        format: string|object|NumberFormat|Partial<NumberFormatConfig>
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        largeStep: number
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        max: number
        min: number
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        step: number
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        unit: string
        width: number|string
    }

    export class DurationColumn extends NumberColumn {
        step: number
        constructor(config?: Partial<DurationColumnConfig>);
    }

    type ResourceCalendarColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class ResourceCalendarColumn extends Column implements AttachToProjectMixin {
        constructor(config?: Partial<ResourceCalendarColumnConfig>);
        attachToAssignmentStore(store: SchedulerAssignmentStore): void;
        attachToCalendarManagerStore(store: Store): void;
        attachToDependencyStore(store: SchedulerDependencyStore): void;
        attachToEventStore(store: SchedulerEventStore): void;
        attachToProject(project: SchedulerProjectModel): void;
        attachToResourceStore(store: SchedulerResourceStore): void;
    }

    type ScaleColumnConfig = {
        align: string
        autoHeight: boolean
        autoSyncHtml: boolean
        autoWidth: boolean|number|number[]
        bubbleEvents: object
        cellCls: string
        cellMenuItems: object
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        draggable: boolean
        editTargetSelector: string
        editor: boolean|string|object|Field|Partial<FieldConfig>
        enableCellContextMenu: boolean
        enableHeaderContextMenu: boolean
        exportable: boolean
        exportedType: string
        field: string
        filterType: string
        filterable: boolean|Function|object
        finalizeCellEdit: Function
        fitMode: string
        flex: number
        groupRenderer: Function
        groupable: boolean
        headerMenuItems: object
        headerRenderer: Function
        hidden: boolean
        hideable: boolean
        htmlEncode: boolean
        htmlEncodeHeaderText: boolean
        icon: string
        id: string|number
        instantUpdate: boolean
        invalidAction: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        locked: boolean
        minWidth: number|string
        parentId: string|number|null
        parentIndex: number
        region: string
        renderer: Function
        resizable: boolean
        responsiveLevels: object
        revertOnEscape: boolean
        searchable: boolean
        showColumnPicker: boolean
        sortable: boolean|Function|object
        sum: string
        summaries: object[]
        summaryRenderer: Function
        tags: string[]
        text: string
        tooltip: string
        tooltipRenderer: Function
        touchConfig: object
        tree: boolean
        width: number|string
    }

    export class ScaleColumn extends Column {
        constructor(config?: Partial<ScaleColumnConfig>);
    }

    type SchedulerProAssignmentStoreConfig = {
        allowNoId: boolean
        autoCommit: boolean
        autoLoad: boolean
        autoTree: boolean
        bubbleEvents: object
        chainedFields: string[]
        chainedFilterFn: Function
        createUrl: string
        data: object[]|Model[]|Partial<ModelConfig>[]
        deleteUrl: string
        doRelayToMaster: string[]
        dontRelayToMaster: string
        fetchOptions: object
        fields: string[]|object[]|DataField[]|Partial<DataFieldConfig>[]
        filterParamName: string
        filters: object|object[]
        groupers: object[]
        headers: object
        httpMethods: object
        id: string|number
        keepUncommittedChanges: boolean
        listeners: object
        masterStore: Store
        modelClass: typeof Model
        pageParamName: string
        pageSize: number
        pageSizeParamName: string
        pageStartParamName: string
        params: object
        parentIdParamName: string
        readUrl: string
        reapplyFilterOnAdd: boolean
        reapplyFilterOnUpdate: boolean
        reapplySortersOnAdd: boolean
        responseDataProperty: string
        responseSuccessProperty: string
        responseTotalProperty: string
        restfulFilter: boolean
        sendAsFormData: boolean
        sortParamName: string
        sorters: object[]|string[]
        stm: StateTrackingManager
        storage: Collection|object|Partial<CollectionConfig>
        syncDataOnLoad: boolean|object
        taskStore: EventStore|object|Partial<EventStoreConfig>
        transformFlatData: boolean
        tree: boolean
        updateUrl: string
        useLocaleSort: boolean|string|object
        useRawData: boolean|object
        useRestfulMethods: boolean
        writeAllFields: boolean
    }

    export class SchedulerProAssignmentStore extends AjaxStore implements PartOfProject, AssignmentStoreMixin {
        assignmentStore: SchedulerProAssignmentStore
        calendarManagerStore: SchedulerProCalendarManagerStore
        data: object[]
        dependencyStore: SchedulerProDependencyStore
        eventStore: EventStore
        project: SchedulerProProjectModel
        resourceStore: SchedulerProResourceStore
        taskStore: EventStore
        constructor(config?: Partial<SchedulerProAssignmentStoreConfig>);
        add(records: SchedulerAssignmentModel|SchedulerAssignmentModel[]|object|object[]|Partial<SchedulerAssignmentModelConfig>|Partial<SchedulerAssignmentModelConfig>[], silent?: boolean): SchedulerAssignmentModel[];
        addAsync(records: SchedulerAssignmentModel|SchedulerAssignmentModel[]|object|object[]|Partial<SchedulerAssignmentModelConfig>|Partial<SchedulerAssignmentModelConfig>[], silent?: boolean): SchedulerAssignmentModel[];
        assignEventToResource(event: TimeSpan, resources: SchedulerResourceModel|SchedulerResourceModel[], assignmentSetupFn?: Function, removeExistingAssignments?: boolean): SchedulerAssignmentModel[];
        getAssignmentForEventAndResource(event: SchedulerEventModel|string|number, resource: SchedulerResourceModel|string|number): SchedulerAssignmentModel;
        getAssignmentsForEvent(event: TimeSpan): SchedulerAssignmentModel[];
        getAssignmentsForResource(resource: SchedulerResourceModel): SchedulerAssignmentModel[];
        getEventsForResource(resource: SchedulerResourceModel|string|number): TimeSpan[];
        getResourcesForEvent(event: SchedulerEventModel): SchedulerResourceModel[];
        isEventAssignedToResource(event: SchedulerEventModel|string|number, resource: SchedulerResourceModel|string|number): boolean;
        loadDataAsync(data: object[]): void;
        mapAssignmentsForEvent(event: SchedulerEventModel, fn?: Function, filterFn?: Function): SchedulerEventModel[]|any[];
        mapAssignmentsForResource(resource: SchedulerResourceModel|number|string, fn?: Function, filterFn?: Function): SchedulerResourceModel[]|any[];
        removeAssignmentsForEvent(event: TimeSpan): void;
        removeAssignmentsForResource(resource: SchedulerResourceModel|any): void;
        unassignEventFromResource(event: TimeSpan|string|number, resources?: SchedulerResourceModel|string|number): SchedulerAssignmentModel|SchedulerAssignmentModel[];
    }

    type SchedulerProCalendarManagerStoreConfig = {
        allowNoId: boolean
        autoCommit: boolean
        autoLoad: boolean
        autoTree: boolean
        bubbleEvents: object
        chainedFields: string[]
        chainedFilterFn: Function
        createUrl: string
        data: object[]|Model[]|Partial<ModelConfig>[]
        deleteUrl: string
        doRelayToMaster: string[]
        dontRelayToMaster: string
        fetchOptions: object
        fields: string[]|object[]|DataField[]|Partial<DataFieldConfig>[]
        filterParamName: string
        filters: object|object[]
        groupers: object[]
        headers: object
        httpMethods: object
        id: string|number
        keepUncommittedChanges: boolean
        listeners: object
        masterStore: Store
        modelClass: typeof Model
        pageParamName: string
        pageSize: number
        pageSizeParamName: string
        pageStartParamName: string
        params: object
        parentIdParamName: string
        readUrl: string
        reapplyFilterOnAdd: boolean
        reapplyFilterOnUpdate: boolean
        reapplySortersOnAdd: boolean
        responseDataProperty: string
        responseSuccessProperty: string
        responseTotalProperty: string
        restfulFilter: boolean
        sendAsFormData: boolean
        sortParamName: string
        sorters: object[]|string[]
        stm: StateTrackingManager
        storage: Collection|object|Partial<CollectionConfig>
        syncDataOnLoad: boolean|object
        taskStore: EventStore|object|Partial<EventStoreConfig>
        transformFlatData: boolean
        tree: boolean
        updateUrl: string
        useLocaleSort: boolean|string|object
        useRawData: boolean|object
        useRestfulMethods: boolean
        writeAllFields: boolean
    }

    export class SchedulerProCalendarManagerStore extends AjaxStore implements PartOfProject {
        assignmentStore: SchedulerProAssignmentStore
        calendarManagerStore: SchedulerProCalendarManagerStore
        dependencyStore: SchedulerProDependencyStore
        eventStore: EventStore
        project: SchedulerProProjectModel
        resourceStore: SchedulerProResourceStore
        taskStore: EventStore
        constructor(config?: Partial<SchedulerProCalendarManagerStoreConfig>);
    }

    type SchedulerProDependencyStoreConfig = {
        allowNoId: boolean
        autoCommit: boolean
        autoLoad: boolean
        autoTree: boolean
        bubbleEvents: object
        chainedFields: string[]
        chainedFilterFn: Function
        createUrl: string
        data: object[]|Model[]|Partial<ModelConfig>[]
        deleteUrl: string
        doRelayToMaster: string[]
        dontRelayToMaster: string
        fetchOptions: object
        fields: string[]|object[]|DataField[]|Partial<DataFieldConfig>[]
        filterParamName: string
        filters: object|object[]
        groupers: object[]
        headers: object
        httpMethods: object
        id: string|number
        keepUncommittedChanges: boolean
        listeners: object
        masterStore: Store
        modelClass: typeof Model
        pageParamName: string
        pageSize: number
        pageSizeParamName: string
        pageStartParamName: string
        params: object
        parentIdParamName: string
        readUrl: string
        reapplyFilterOnAdd: boolean
        reapplyFilterOnUpdate: boolean
        reapplySortersOnAdd: boolean
        responseDataProperty: string
        responseSuccessProperty: string
        responseTotalProperty: string
        restfulFilter: boolean
        sendAsFormData: boolean
        sortParamName: string
        sorters: object[]|string[]
        stm: StateTrackingManager
        storage: Collection|object|Partial<CollectionConfig>
        syncDataOnLoad: boolean|object
        taskStore: EventStore|object|Partial<EventStoreConfig>
        transformFlatData: boolean
        tree: boolean
        updateUrl: string
        useLocaleSort: boolean|string|object
        useRawData: boolean|object
        useRestfulMethods: boolean
        writeAllFields: boolean
    }

    export class SchedulerProDependencyStore extends AjaxStore implements PartOfProject, DependencyStoreMixin {
        assignmentStore: SchedulerProAssignmentStore
        calendarManagerStore: SchedulerProCalendarManagerStore
        data: object[]
        dependencyStore: SchedulerProDependencyStore
        eventStore: EventStore
        project: SchedulerProProjectModel
        resourceStore: SchedulerProResourceStore
        taskStore: EventStore
        constructor(config?: Partial<SchedulerProDependencyStoreConfig>);
        add(records: SchedulerDependencyModel|SchedulerDependencyModel[]|object|object[]|Partial<SchedulerDependencyModelConfig>|Partial<SchedulerDependencyModelConfig>[], silent?: boolean): SchedulerDependencyModel[];
        addAsync(records: SchedulerDependencyModel|SchedulerDependencyModel[]|object|object[]|Partial<SchedulerDependencyModelConfig>|Partial<SchedulerDependencyModelConfig>[], silent?: boolean): SchedulerDependencyModel[];
        getDependencyForSourceAndTargetEvents(sourceEvent: SchedulerEventModel|string, targetEvent: SchedulerEventModel|string): SchedulerDependencyModel;
        getEventDependencies(event: SchedulerEventModel): SchedulerDependencyModel[];
        getEventPredecessors(event: SchedulerEventModel): SchedulerDependencyModel[];
        getEventSuccessors(event: SchedulerEventModel): SchedulerDependencyModel[];
        getEventsLinkingDependency(sourceEvent: SchedulerEventModel|string, targetEvent: SchedulerEventModel|string): SchedulerDependencyModel;
        getHighlightedDependencies(cls: string): DependencyBaseModel[];
        isValidDependency(dependencyOrFromId: SchedulerDependencyModel|number|string, toId?: number|string, type?: number): boolean;
        isValidDependencyToCreate(fromId: number|string, toId: number|string, type: number): boolean;
        loadDataAsync(data: object[]): void;
    }

    type EventStoreConfig = {
        allowNoId: boolean
        autoCommit: boolean
        autoLoad: boolean
        autoTree: boolean
        bubbleEvents: object
        chainedFields: string[]
        chainedFilterFn: Function
        createUrl: string
        data: object[]|Model[]|Partial<ModelConfig>[]
        deleteUrl: string
        doRelayToMaster: string[]
        dontRelayToMaster: string
        fetchOptions: object
        fields: string[]|object[]|DataField[]|Partial<DataFieldConfig>[]
        filterParamName: string
        filters: object|object[]
        groupers: object[]
        headers: object
        httpMethods: object
        id: string|number
        keepUncommittedChanges: boolean
        listeners: object
        masterStore: Store
        modelClass: typeof Model
        pageParamName: string
        pageSize: number
        pageSizeParamName: string
        pageStartParamName: string
        params: object
        parentIdParamName: string
        readUrl: string
        reapplyFilterOnAdd: boolean
        reapplyFilterOnUpdate: boolean
        reapplySortersOnAdd: boolean
        removeUnassignedEvent: boolean
        responseDataProperty: string
        responseSuccessProperty: string
        responseTotalProperty: string
        restfulFilter: boolean
        sendAsFormData: boolean
        sortParamName: string
        sorters: object[]|string[]
        stm: StateTrackingManager
        storage: Collection|object|Partial<CollectionConfig>
        syncDataOnLoad: boolean|object
        taskStore: EventStore|object|Partial<EventStoreConfig>
        transformFlatData: boolean
        tree: boolean
        updateUrl: string
        useLocaleSort: boolean|string|object
        useRawData: boolean|object
        useRestfulMethods: boolean
        writeAllFields: boolean
        onLoadDateRange: Function
    }

    export class EventStore extends AjaxStore implements PartOfProject, SharedEventStoreMixin, EventStoreMixin, RecurringEventsMixin {
        assignmentStore: SchedulerProAssignmentStore
        calendarManagerStore: SchedulerProCalendarManagerStore
        data: object[]
        dependencyStore: SchedulerProDependencyStore
        eventStore: EventStore
        modelClass: typeof EventModel
        project: SchedulerProProjectModel
        resourceStore: SchedulerProResourceStore
        taskStore: EventStore
        onLoadDateRange: Function
        constructor(config?: Partial<EventStoreConfig>);
        add(records: SchedulerEventModel|SchedulerEventModel[]|object|object[]|Partial<SchedulerEventModelConfig>|Partial<SchedulerEventModelConfig>[], silent?: boolean): SchedulerEventModel[];
        addAsync(records: SchedulerEventModel|SchedulerEventModel[]|object|object[]|Partial<SchedulerEventModelConfig>|Partial<SchedulerEventModelConfig>[], silent?: boolean): SchedulerEventModel[];
        append(record: SchedulerEventModel): void;
        assignEventToResource(event: SchedulerEventModel|string|number, resource: SchedulerResourceModel|string|number|SchedulerResourceModel[]|string[]|number[], removeExistingAssignments?: boolean): SchedulerAssignmentModel[];
        forEachScheduledEvent(fn: Function, thisObj: object): void;
        getAssignmentsForEvent(event: SchedulerEventModel|string|number): SchedulerAssignmentModel[];
        getAssignmentsForResource(resource: SchedulerResourceModel|string|number): SchedulerAssignmentModel[];
        getEvents(options: object): SchedulerEventModel[]|Map<any, any>;
        getEventsByStartDate(startDate: Date): SchedulerEventModel[];
        getEventsForResource(resource: SchedulerResourceModel|string|number): SchedulerEventModel[];
        getEventsInTimeSpan(startDate: Date, endDate: Date, allowPartial?: boolean, onlyAssigned?: boolean): SchedulerEventModel[];
        getRecurringEvents(): SchedulerEventModel[];
        getRecurringTimeSpans(): TimeSpan[];
        getResourcesForEvent(event: SchedulerEventModel|string|number): SchedulerResourceModel[];
        getTotalTimeSpan(): object;
        isDateRangeAvailable(start: Date, end: Date, excludeEvent: SchedulerEventModel|null, resource: SchedulerResourceModel): boolean;
        isEventAssignedToResource(event: SchedulerEventModel|string|number, resource: SchedulerResourceModel|string|number): boolean;
        isEventPersistable(event: SchedulerEventModel): boolean;
        loadDataAsync(data: object[]): void;
        reassignEventFromResourceToResource(event: SchedulerEventModel, oldResource: SchedulerResourceModel|SchedulerResourceModel[], newResource: SchedulerResourceModel|SchedulerResourceModel[]): void;
        removeAssignmentsForEvent(event: SchedulerEventModel|string|number): void;
        removeAssignmentsForResource(resource: SchedulerResourceModel|string|number): void;
        unassignEventFromResource(event: SchedulerEventModel|string|number, resource: SchedulerResourceModel|string|number): void;
    }

    type SchedulerProResourceStoreConfig = {
        allowNoId: boolean
        autoCommit: boolean
        autoLoad: boolean
        autoTree: boolean
        bubbleEvents: object
        chainedFields: string[]
        chainedFilterFn: Function
        createUrl: string
        data: object[]|Model[]|Partial<ModelConfig>[]
        deleteUrl: string
        doRelayToMaster: string[]
        dontRelayToMaster: string
        fetchOptions: object
        fields: string[]|object[]|DataField[]|Partial<DataFieldConfig>[]
        filterParamName: string
        filters: object|object[]
        groupers: object[]
        headers: object
        httpMethods: object
        id: string|number
        keepUncommittedChanges: boolean
        listeners: object
        masterStore: Store
        modelClass: typeof Model
        pageParamName: string
        pageSize: number
        pageSizeParamName: string
        pageStartParamName: string
        params: object
        parentIdParamName: string
        readUrl: string
        reapplyFilterOnAdd: boolean
        reapplyFilterOnUpdate: boolean
        reapplySortersOnAdd: boolean
        responseDataProperty: string
        responseSuccessProperty: string
        responseTotalProperty: string
        restfulFilter: boolean
        sendAsFormData: boolean
        sortParamName: string
        sorters: object[]|string[]
        stm: StateTrackingManager
        storage: Collection|object|Partial<CollectionConfig>
        syncDataOnLoad: boolean|object
        taskStore: EventStore|object|Partial<EventStoreConfig>
        transformFlatData: boolean
        tree: boolean
        updateUrl: string
        useLocaleSort: boolean|string|object
        useRawData: boolean|object
        useRestfulMethods: boolean
        writeAllFields: boolean
    }

    export class SchedulerProResourceStore extends AjaxStore implements PartOfProject, ResourceStoreMixin {
        assignmentStore: SchedulerProAssignmentStore
        calendarManagerStore: SchedulerProCalendarManagerStore
        data: object[]
        dependencyStore: SchedulerProDependencyStore
        eventStore: EventStore
        project: SchedulerProProjectModel
        resourceStore: SchedulerProResourceStore
        taskStore: EventStore
        constructor(config?: Partial<SchedulerProResourceStoreConfig>);
        add(records: SchedulerResourceModel|SchedulerResourceModel[]|object|object[]|Partial<SchedulerResourceModelConfig>|Partial<SchedulerResourceModelConfig>[], silent?: boolean): SchedulerResourceModel[];
        addAsync(records: SchedulerResourceModel|SchedulerResourceModel[]|object|object[]|Partial<SchedulerResourceModelConfig>|Partial<SchedulerResourceModelConfig>[], silent?: boolean): SchedulerResourceModel[];
        loadDataAsync(data: object[]): void;
    }

    type PartOfProjectConfig = {
        taskStore: EventStore|object|Partial<EventStoreConfig>
    }

    export class PartOfProject {
        assignmentStore: SchedulerProAssignmentStore
        calendarManagerStore: SchedulerProCalendarManagerStore
        dependencyStore: SchedulerProDependencyStore
        eventStore: EventStore
        project: SchedulerProProjectModel
        resourceStore: SchedulerProResourceStore
        taskStore: EventStore
        constructor(config?: Partial<PartOfProjectConfig>);
    }

    type ProjectCrudManagerConfig = {
        autoLoad: boolean
        autoSync: boolean
        autoSyncTimeout: number
        bubbleEvents: object
        crudStores: Store[]|string[]|object[]|Partial<StoreConfig>[]
        encoder: object
        listeners: object
        phantomIdField: string
        phantomParentIdField: string
        project: SchedulerProjectModel
        resetIdsBeforeSync: boolean
        skipSuccessProperty: boolean
        storeIdProperty: string
        supportShortSyncResponse: boolean
        syncApplySequence: string[]
        trackResponseType: boolean
        transport: object
        validateResponse: boolean
        writeAllFields: boolean
        onBeforeDestroy: Function
        onBeforeLoad: Function
        onBeforeLoadApply: Function
        onBeforeResponseApply: Function
        onBeforeSend: Function
        onBeforeSync: Function
        onBeforeSyncApply: Function
        onCatchAll: Function
        onDestroy: Function
        onHasChanges: Function
        onLoad: Function
        onLoadCanceled: Function
        onLoadFail: Function
        onNoChanges: Function
        onRequestDone: Function
        onRequestFail: Function
        onSync: Function
        onSyncCanceled: Function
        onSyncDelayed: Function
        onSyncFail: Function
    }

    export class ProjectCrudManager implements SchedulerProjectCrudManager {
        changes: object
        crudRevision: number
        crudStores: object[]
        isCrudManagerLoading: boolean
        isCrudManagerSyncing: boolean
        syncApplySequence: object[]
        onBeforeDestroy: Function
        onBeforeLoad: Function
        onBeforeLoadApply: Function
        onBeforeResponseApply: Function
        onBeforeSend: Function
        onBeforeSync: Function
        onBeforeSyncApply: Function
        onCatchAll: Function
        onDestroy: Function
        onHasChanges: Function
        onLoad: Function
        onLoadCanceled: Function
        onLoadFail: Function
        onNoChanges: Function
        onRequestDone: Function
        onRequestFail: Function
        onSync: Function
        onSyncCanceled: Function
        onSyncDelayed: Function
        onSyncFail: Function
        constructor(config?: Partial<ProjectCrudManagerConfig>);
        acceptChanges(): void;
        addCrudStore(store: Store|string|object|Store[]|string[]|object[]|Partial<StoreConfig>|Partial<StoreConfig>[], position?: number, fromStore?: string|Store|object|Partial<StoreConfig>): void;
        addListener(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        addStoreToApplySequence(store: Store|object|Store[]|object[]|Partial<StoreConfig>|Partial<StoreConfig>[], position?: number, fromStore?: string|Store|object|Partial<StoreConfig>): void;
        cancelRequest(requestPromise: Promise<any>): void;
        commitCrudStores(): void;
        crudStoreHasChanges(storeId?: string|Store): boolean;
        decode(responseText: string): object;
        doDestroy(): void;
        encode(requestData: object): string;
        getCrudStore(storeId: string): Store;
        getStoreDescriptor(storeId: string|Store): object;
        hasListener(eventName: string): boolean;
        load(options?: object): Promise<any>;
        loadCrudManagerData(response: object, options?: object): void;
        on(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        rejectCrudStores(): void;
        relayAll(through: Events, prefix: string, transformCase?: boolean): void;
        removeAllListeners(): void;
        removeCrudStore(store: object|string|Store|Partial<StoreConfig>): void;
        removeListener(config: object, thisObj: object): void;
        removeStoreFromApplySequence(store: object|string|Store|Partial<StoreConfig>): void;
        resumeAutoSync(doSync?: boolean): void;
        resumeEvents(): void;
        revertChanges(): void;
        sendRequest(request: object): Promise<any>;
        suspendAutoSync(): void;
        suspendEvents(queue?: boolean): void;
        sync(): Promise<any>;
        trigger(eventName: string, param?: object): boolean|Promise<any>;
        un(config: object, thisObj?: object): void;
    }

    type EventResizeConfig = {
        allowResizeToZero: boolean
        bottomHandle: boolean
        bubbleEvents: object
        disabled: boolean
        dragThreshold: number
        dynamicHandleSize: boolean
        handleSize: number
        leftHandle: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        reservedSpace: number
        rightHandle: boolean
        showExactResizePosition: boolean
        tip: Tooltip|object|Partial<TooltipConfig>
        tooltipTemplate: Function
        topHandle: boolean
        touchHandleSize: number
        validatorFn: Function
        validatorFnThisObj: object
    }

    export class EventResize extends SchedulerEventResize {
        constructor(config?: Partial<EventResizeConfig>);
    }

    type PercentBarConfig = {
        allowResize: boolean
        bubbleEvents: object
        disabled: boolean
        displayField: string
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        showPercentage: boolean
        valueField: string
    }

    export class PercentBar extends InstancePlugin {
        constructor(config?: Partial<PercentBarConfig>);
    }

    type ResourceNonWorkingTimeConfig = {
        bubbleEvents: object
        disabled: boolean
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        maxTimeAxisUnit: string
        resourceTimeRangeModelClass: Function
    }

    export class ResourceNonWorkingTime extends ResourceTimeRangesBase {
        constructor(config?: Partial<ResourceNonWorkingTimeConfig>);
    }

    type SchedulerProTaskEditConfig = {
        bubbleEvents: object
        confirmDelete: boolean
        disabled: boolean
        editorClass: Widget
        editorConfig: object
        items: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        saveAndCloseOnEnter: boolean
        scrollIntoView: boolean
        showDeleteButton: boolean
        triggerEvent: string
        weekStartDay: number
        onAfterEventSave: Function
        onAfterTaskSave: Function
        onBeforeEventDelete: Function
        onBeforeEventSave: Function
        onBeforeTaskDelete: Function
        onBeforeTaskEdit: Function
        onBeforeTaskEditShow: Function
        onBeforeTaskSave: Function
    }

    export class SchedulerProTaskEdit extends InstancePlugin implements ProTaskEditStm, Delayable {
        isEditing: boolean
        onAfterEventSave: Function
        onAfterTaskSave: Function
        onBeforeEventDelete: Function
        onBeforeEventSave: Function
        onBeforeTaskDelete: Function
        onBeforeTaskEdit: Function
        onBeforeTaskEditShow: Function
        onBeforeTaskSave: Function
        constructor(config?: Partial<SchedulerProTaskEditConfig>);
        editEvent(taskRecord: EventModel|Function, resourceRecord?: SchedulerProResourceModel, element?: HTMLElement): Promise<any>;
    }

    export class ProTaskEditStm {
    }

    type SchedulerProAssignmentModelConfig = {
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        drawDependencies: boolean
        event: string|number
        eventId: string|number
        id: string|number
        parentId: string|number|null
        parentIndex: number
        resource: string|number
        resourceId: string|number
    }

    export class SchedulerProAssignmentModel extends Model implements AssignmentModelMixin {
        drawDependencies: boolean
        event: string|number
        eventId: string|number
        eventName: string
        isPersistable: boolean
        resource: string|number
        resourceId: string|number
        resourceName: string
        constructor(config?: Partial<SchedulerProAssignmentModelConfig>);
        getResource(): SchedulerResourceModel;
        setAsync(field: string|object, value: any, silent?: boolean): void;
        toString(): string;
    }

    type SchedulerProCalendarIntervalModelConfig = {
        endDate: Date
        isWorking: boolean
        recurrentEndDate: string
        recurrentStartDate: string
        startDate: Date
    }

    export class SchedulerProCalendarIntervalModel {
        endDate: Date
        isWorking: boolean
        recurrentEndDate: string
        recurrentStartDate: string
        startDate: Date
        constructor(config?: Partial<SchedulerProCalendarIntervalModelConfig>);
        getEndDateSchedule(): object;
        getStartDateSchedule(): object;
        isRecurrent(): boolean;
        isStatic(): boolean;
    }

    type SchedulerProCalendarModelConfig = {
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        id: string|number
        intervals: SchedulerProCalendarIntervalModel[]
        name: string
        parentId: string|number|null
        parentIndex: number
        taskStore: EventStore|object|Partial<EventStoreConfig>
        unspecifiedTimeIsWorking: boolean
    }

    export class SchedulerProCalendarModel extends Model implements PartOfProject {
        assignmentStore: SchedulerProAssignmentStore
        calendarManagerStore: SchedulerProCalendarManagerStore
        dependencyStore: SchedulerProDependencyStore
        eventStore: EventStore
        intervals: SchedulerProCalendarIntervalModel[]
        name: string
        project: SchedulerProProjectModel
        resourceStore: SchedulerProResourceStore
        taskStore: EventStore
        unspecifiedTimeIsWorking: boolean
        constructor(config?: Partial<SchedulerProCalendarModelConfig>);
        addInterval(interval: SchedulerProCalendarIntervalModel|object|Partial<SchedulerProCalendarIntervalModelConfig>): SchedulerProCalendarIntervalModel[];
        addIntervals(intervals: SchedulerProCalendarIntervalModel[]|object[]|Partial<SchedulerProCalendarIntervalModelConfig>[]): SchedulerProCalendarIntervalModel[];
        calculateDurationMs(startDate: Date, endDate: Date): number;
        isWorkingTime(startDate: Date, endDate: Date): boolean;
        skipNonWorkingTime(date: Date, isForward?: boolean): Date;
    }

    type SchedulerProDependencyModelConfig = {
        active: boolean
        bidirectional: boolean
        calendar: SchedulerProCalendarModel
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        from: string|number
        fromEvent: string|number|SchedulerEventModel
        fromSide: string
        id: string|number
        lag: number
        lagUnit: string
        parentId: string|number|null
        parentIndex: number
        taskStore: EventStore|object|Partial<EventStoreConfig>
        to: string|number
        toEvent: string|number|SchedulerEventModel
        toSide: string
        type: number
    }

    export class SchedulerProDependencyModel extends DependencyBaseModel implements PartOfProject {
        active: boolean
        assignmentStore: SchedulerProAssignmentStore
        calendar: SchedulerProCalendarModel
        calendarManagerStore: SchedulerProCalendarManagerStore
        dependencyStore: SchedulerProDependencyStore
        eventStore: EventStore
        project: SchedulerProProjectModel
        resourceStore: SchedulerProResourceStore
        taskStore: EventStore
        constructor(config?: Partial<SchedulerProDependencyModelConfig>);
    }

    type EventModelConfig = {
        allDay: boolean
        calendar: SchedulerProCalendarModel
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: DomClassList|string
        constraintDate: Date
        constraintType: string
        draggable: boolean
        duration: number
        durationUnit: string
        earlyEndDate: Date
        earlyStartDate: Date
        effort: number
        effortUnit: string
        endDate: string|Date
        eventColor: string
        eventStyle: string
        exceptionDates: string|string[]
        iconCls: string
        id: string|number
        manuallyScheduled: boolean
        milestoneWidth: number
        name: string
        note: string
        parentId: string|number|null
        parentIndex: number
        percentDone: number
        recurrenceRule: string
        resizable: boolean|string
        resourceId: string|number
        resources: string|number
        showInTimeline: boolean
        startDate: string|Date
        stickyContents: boolean
        style: string
        taskStore: EventStore|object|Partial<EventStoreConfig>
    }

    export class EventModel extends TimeSpan implements RecurringTimeSpan, EventModelMixin, PercentDoneMixin, PartOfProject {
        allDay: boolean
        assignmentStore: SchedulerProAssignmentStore
        assignments: SchedulerAssignmentModel[]
        calendar: SchedulerProCalendarModel
        calendarManagerStore: SchedulerProCalendarManagerStore
        constraintDate: Date
        constraintType: string
        dependencyStore: SchedulerProDependencyStore
        draggable: boolean
        duration: number
        earlyEndDate: Date
        earlyStartDate: Date
        effort: number
        effortUnit: string
        endDate: string|Date
        eventColor: string
        eventStore: EventStore
        eventStyle: string
        exceptionDates: string|string[]
        fullDuration: Duration
        id: string|number
        isCompleted: boolean
        isDraggable: boolean
        isInProgress: boolean
        isInterDay: boolean
        isOccurrence: boolean
        isPersistable: boolean
        isRecurring: boolean
        isResizable: boolean|string
        isStarted: boolean
        manuallyScheduled: boolean
        milestoneWidth: number
        note: string
        occurrenceIndex: number
        percentDone: number
        predecessors: DependencyBaseModel[]
        project: SchedulerProProjectModel
        recurrence: RecurrenceModel
        recurrenceModel: string
        recurrenceRule: string
        renderedPercentDone: number
        resizable: boolean|string
        resource: SchedulerResourceModel
        resourceId: string|number
        resourceStore: SchedulerProResourceStore
        resources: SchedulerResourceModel[]
        showInTimeline: boolean
        startDate: string|Date
        stickyContents: boolean
        successors: DependencyBaseModel[]
        supportsRecurring: boolean
        taskStore: EventStore
        constructor(config?: Partial<EventModelConfig>);
        assign(resource: SchedulerResourceModel|string|number|SchedulerResourceModel[]|string[]|number[], removeExistingAssignments?: boolean): void;
        getAssignmentFor(resource: SchedulerProResourceModel): SchedulerProAssignmentModel|null;
        getCalendar(): SchedulerProCalendarModel;
        getOccurrencesForDateRange(startDate: Date, endDate?: Date): TimeSpan[];
        getResource(resourceId?: string): SchedulerResourceModel;
        hasException(date: Date): boolean;
        isAssignedTo(resource: SchedulerResourceModel|string|number): boolean;
        isEditable(fieldName: string): boolean;
        reassign(oldResourceId: SchedulerResourceModel|string|number, newResourceId: SchedulerResourceModel|string|number): void;
        remove(): void;
        setAsync(field: string|object, value: any, silent?: boolean): void;
        setCalendar(calendar: SchedulerProCalendarModel): Promise<any>;
        setConstraint(constraintType: string, constraintDate?: Date): Promise<any>;
        setDuration(duration: number, unit?: string): Promise<any>;
        setEffort(effort: number, unit?: string): Promise<any>;
        setEndDate(date: Date, keepDuration?: boolean): Promise<any>;
        setRecurrence(recurrence: object|string|RecurrenceModel|Partial<RecurrenceModelConfig>, interval?: number, recurrenceEnd?: number|Date): void;
        setStartDate(date: Date, keepDuration?: boolean): Promise<any>;
        shift(unit: string, amount: number): Promise<any>;
        unassign(resource?: SchedulerResourceModel|string|number): void;
    }

    type SchedulerProProjectModelConfig = {
        assignmentModelClass: SchedulerProAssignmentModel
        assignmentStore: SchedulerAssignmentStore|object|Partial<SchedulerAssignmentStoreConfig>
        assignmentStoreClass: SchedulerProAssignmentStore|object|Partial<SchedulerProAssignmentStoreConfig>
        assignmentsData: SchedulerAssignmentModel[]
        autoLoad: boolean
        autoSync: boolean
        autoSyncTimeout: number
        bubbleEvents: object
        calendar: string|object|SchedulerProCalendarModel|Partial<SchedulerProCalendarModelConfig>
        calendarManagerStoreClass: SchedulerProCalendarManagerStore|object|Partial<SchedulerProCalendarManagerStoreConfig>
        calendarModelClass: SchedulerProCalendarModel
        calendarsData: SchedulerProCalendarModel[]
        crudStores: Store[]|string[]|object[]|Partial<StoreConfig>[]
        daysPerMonth: number
        daysPerWeek: number
        dependenciesCalendar: string
        dependenciesData: SchedulerDependencyModel[]
        dependencyModelClass: SchedulerProDependencyModel
        dependencyStore: SchedulerDependencyStore|object|Partial<SchedulerDependencyStoreConfig>
        dependencyStoreClass: SchedulerProDependencyStore|object|Partial<SchedulerProDependencyStoreConfig>
        direction: string
        enableProgressNotifications: boolean
        encoder: object
        eventModelClass: EventModel
        eventStore: SchedulerEventStore|object|Partial<SchedulerEventStoreConfig>
        eventStoreClass: EventStore|object|Partial<EventStoreConfig>
        eventsData: SchedulerEventModel[]
        hoursPerDay: number
        json: string
        listeners: object
        phantomIdField: string
        phantomParentIdField: string
        project: SchedulerProjectModel
        resetIdsBeforeSync: boolean
        resourceModelClass: SchedulerProResourceModel
        resourceStore: SchedulerResourceStore|object|Partial<SchedulerResourceStoreConfig>
        resourceStoreClass: SchedulerProResourceStore|object|Partial<SchedulerProResourceStoreConfig>
        resourceTimeRangeStore: ResourceTimeRangeStore|object|Partial<ResourceTimeRangeStoreConfig>
        resourceTimeRangeStoreClass: ResourceTimeRangeStore|object|Partial<ResourceTimeRangeStoreConfig>
        resourceTimeRangesData: ResourceTimeRangeModel[]
        resourcesData: SchedulerResourceModel[]
        silenceInitialCommit: boolean
        skipSuccessProperty: boolean
        stm: object|StateTrackingManager|Partial<StateTrackingManagerConfig>
        storeIdProperty: string
        supportShortSyncResponse: boolean
        syncApplySequence: string[]
        taskStore: EventStore|object|Partial<EventStoreConfig>
        timeRangeStore: Store|object|Partial<StoreConfig>
        timeRangeStoreClass: Store|object|Partial<StoreConfig>
        timeRangesData: TimeSpan[]
        trackResponseType: boolean
        transport: object
        validateResponse: boolean
        writeAllFields: boolean
        onBeforeDestroy: Function
        onBeforeLoad: Function
        onBeforeLoadApply: Function
        onBeforeResponseApply: Function
        onBeforeSend: Function
        onBeforeSync: Function
        onBeforeSyncApply: Function
        onCatchAll: Function
        onDestroy: Function
        onHasChanges: Function
        onLoad: Function
        onLoadCanceled: Function
        onLoadFail: Function
        onNoChanges: Function
        onProgress: Function
        onRequestDone: Function
        onRequestFail: Function
        onSync: Function
        onSyncCanceled: Function
        onSyncDelayed: Function
        onSyncFail: Function
    }

    export class SchedulerProProjectModel extends ProjectModelMixin implements PartOfProject, ProjectCrudManager, Events {
        assignmentStore: SchedulerProAssignmentStore
        calendar: SchedulerProCalendarModel
        calendarManagerStore: SchedulerProCalendarManagerStore
        changes: object
        crudRevision: number
        crudStores: object[]
        daysPerMonth: number
        daysPerWeek: number
        dependenciesCalendar: string
        dependencyStore: SchedulerProDependencyStore
        direction: string
        enableProgressNotifications: boolean
        eventStore: EventStore
        hoursPerDay: number
        isCrudManagerLoading: boolean
        isCrudManagerSyncing: boolean
        project: SchedulerProProjectModel
        resourceStore: SchedulerProResourceStore
        syncApplySequence: object[]
        taskStore: EventStore
        onBeforeDestroy: Function
        onBeforeLoad: Function
        onBeforeLoadApply: Function
        onBeforeResponseApply: Function
        onBeforeSend: Function
        onBeforeSync: Function
        onBeforeSyncApply: Function
        onCatchAll: Function
        onDestroy: Function
        onHasChanges: Function
        onLoad: Function
        onLoadCanceled: Function
        onLoadFail: Function
        onNoChanges: Function
        onProgress: Function
        onRequestDone: Function
        onRequestFail: Function
        onSync: Function
        onSyncCanceled: Function
        onSyncDelayed: Function
        onSyncFail: Function
        constructor(config?: Partial<SchedulerProProjectModelConfig>);
        acceptChanges(): void;
        addCrudStore(store: Store|string|object|Store[]|string[]|object[]|Partial<StoreConfig>|Partial<StoreConfig>[], position?: number, fromStore?: string|Store|object|Partial<StoreConfig>): void;
        addListener(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        addStoreToApplySequence(store: Store|object|Store[]|object[]|Partial<StoreConfig>|Partial<StoreConfig>[], position?: number, fromStore?: string|Store|object|Partial<StoreConfig>): void;
        cancelRequest(requestPromise: Promise<any>): void;
        commitAsync(): Promise<any>;
        commitCrudStores(): void;
        crudStoreHasChanges(storeId?: string|Store): boolean;
        decode(responseText: string): object;
        doDestroy(): void;
        encode(requestData: object): string;
        getCrudStore(storeId: string): Store;
        getStoreDescriptor(storeId: string|Store): object;
        hasListener(eventName: string): boolean;
        load(options?: object): Promise<any>;
        loadCrudManagerData(response: object, options?: object): void;
        on(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        propagate(): Promise<any>;
        rejectCrudStores(): void;
        relayAll(through: Events, prefix: string, transformCase?: boolean): void;
        removeAllListeners(): void;
        removeCrudStore(store: object|string|Store|Partial<StoreConfig>): void;
        removeListener(config: object, thisObj: object): void;
        removeStoreFromApplySequence(store: object|string|Store|Partial<StoreConfig>): void;
        resumeAutoSync(doSync?: boolean): void;
        resumeEvents(): void;
        revertChanges(): void;
        sendRequest(request: object): Promise<any>;
        suspendAutoSync(): void;
        suspendEvents(queue?: boolean): void;
        sync(): Promise<any>;
        trigger(eventName: string, param?: object): boolean|Promise<any>;
        un(config: object, thisObj?: object): void;
    }

    type SchedulerProResourceModelConfig = {
        barMargin: number
        calendar: SchedulerProCalendarModel
        children: boolean|object[]|Model[]|Partial<ModelConfig>[]
        cls: string
        eventColor: string
        eventLayout: string
        eventStyle: string
        expanded: boolean
        href: string
        iconCls: string
        id: string|number
        image: string
        imageUrl: string
        name: string
        parentId: string|number|null
        parentIndex: number
        resourceMargin: number
        rowHeight: number
        target: string
    }

    export class SchedulerProResourceModel extends GridRowModel implements ResourceModelMixin {
        assignments: SchedulerAssignmentModel[]
        barMargin: number
        calendar: SchedulerProCalendarModel
        eventColor: string
        eventLayout: string
        eventStyle: string
        events: SchedulerEventModel[]
        id: string|number
        image: string
        imageUrl: string
        initials: string
        isPersistable: boolean
        name: string
        resourceMargin: number
        rowHeight: number
        constructor(config?: Partial<SchedulerProResourceModelConfig>);
        getCalendar(): SchedulerProCalendarModel;
        getEvents(): SchedulerEventModel[];
        setAsync(field: string|object, value: any, silent?: boolean): void;
        setCalendar(calendar: SchedulerProCalendarModel): Promise<any>;
        unassignAll(): void;
    }

    type PercentDoneMixinConfig = {
        percentDone: number
    }

    export class PercentDoneMixin {
        isCompleted: boolean
        isInProgress: boolean
        isStarted: boolean
        percentDone: number
        renderedPercentDone: number
        constructor(config?: Partial<PercentDoneMixinConfig>);
    }

    type ResourceHistogramFeaturesType = {
        cellEdit: GridCellEdit
        cellMenu: CellMenu
        cellTooltip: CellTooltip
        columnAutoWidth: ColumnAutoWidth
        columnDragToolbar: ColumnDragToolbar
        columnLines: ColumnLines
        columnPicker: ColumnPicker
        columnReorder: ColumnReorder
        columnResize: ColumnResize
        contextMenu: ContextMenu
        dependencies: SchedulerDependencies
        dependencyEdit: SchedulerDependencyEdit
        eventContextMenu: EventContextMenu
        eventCopyPaste: EventCopyPaste
        eventDrag: EventDrag
        eventDragCreate: EventDragCreate
        eventDragSelect: EventDragSelect
        eventEdit: EventEdit
        eventFilter: EventFilter
        eventMenu: EventMenu
        eventResize: EventResize
        eventTooltip: EventTooltip
        excelExporter: ExcelExporter
        filter: Filter
        filterBar: FilterBar
        group: Group
        groupSummary: GroupSummary
        headerContextMenu: HeaderContextMenu
        headerMenu: HeaderMenu
        headerZoom: HeaderZoom
        labels: SchedulerLabels
        nonWorkingTime: NonWorkingTime
        pan: Pan
        pdfExport: SchedulerPdfExport
        percentBar: PercentBar
        quickFind: QuickFind
        regionResize: RegionResize
        resourceNonWorkingTime: ResourceNonWorkingTime
        resourceTimeRanges: ResourceTimeRanges
        rowCopyPaste: RowCopyPaste
        rowReorder: RowReorder
        scheduleContext: ScheduleContext
        scheduleContextMenu: ScheduleContextMenu
        scheduleMenu: ScheduleMenu
        scheduleTooltip: ScheduleTooltip
        search: Search
        simpleEventEdit: SimpleEventEdit
        sort: Sort
        stickyCells: StickyCells
        stickyEvents: StickyEvents
        stripe: Stripe
        summary: Summary
        taskEdit: SchedulerProTaskEdit
        timeAxisHeaderMenu: TimeAxisHeaderMenu
        timeRanges: TimeRanges
        tree: Tree
    }

    type ResourceHistogramFeaturesConfigType = {
        cellEdit: string|boolean|Partial<GridCellEditConfig>
        cellMenu: string|boolean|Partial<CellMenuConfig>
        cellTooltip: string|boolean|Partial<CellTooltipConfig>
        columnAutoWidth: string|boolean|Partial<ColumnAutoWidthConfig>
        columnDragToolbar: string|boolean|Partial<ColumnDragToolbarConfig>
        columnLines: string|boolean|Partial<ColumnLinesConfig>
        columnPicker: string|boolean|Partial<ColumnPickerConfig>
        columnReorder: string|boolean|Partial<ColumnReorderConfig>
        columnResize: string|boolean|Partial<ColumnResizeConfig>
        contextMenu: string|boolean|Partial<ContextMenuConfig>
        dependencies: string|boolean|Partial<SchedulerDependenciesConfig>
        dependencyEdit: string|boolean|Partial<SchedulerDependencyEditConfig>
        eventContextMenu: string|boolean|Partial<EventContextMenuConfig>
        eventCopyPaste: string|boolean|Partial<EventCopyPasteConfig>
        eventDrag: string|boolean|Partial<EventDragConfig>
        eventDragCreate: string|boolean|Partial<EventDragCreateConfig>
        eventDragSelect: string|boolean|Partial<EventDragSelectConfig>
        eventEdit: string|boolean|Partial<EventEditConfig>
        eventFilter: string|boolean|Partial<EventFilterConfig>
        eventMenu: string|boolean|Partial<EventMenuConfig>
        eventResize: string|boolean|Partial<EventResizeConfig>
        eventTooltip: string|boolean|Partial<EventTooltipConfig>
        excelExporter: string|boolean|Partial<ExcelExporterConfig>
        filter: string|boolean|Partial<FilterConfig>
        filterBar: string|boolean|Partial<FilterBarConfig>
        group: string|boolean|Partial<GroupConfig>
        groupSummary: string|boolean|Partial<GroupSummaryConfig>
        headerContextMenu: string|boolean|Partial<HeaderContextMenuConfig>
        headerMenu: string|boolean|Partial<HeaderMenuConfig>
        headerZoom: string|boolean|Partial<HeaderZoomConfig>
        labels: string|boolean|Partial<SchedulerLabelsConfig>
        nonWorkingTime: string|boolean|Partial<NonWorkingTimeConfig>
        pan: string|boolean|Partial<PanConfig>
        pdfExport: string|boolean|Partial<SchedulerPdfExportConfig>
        percentBar: string|boolean|Partial<PercentBarConfig>
        quickFind: string|boolean|Partial<QuickFindConfig>
        regionResize: string|boolean|Partial<RegionResizeConfig>
        resourceNonWorkingTime: string|boolean|Partial<ResourceNonWorkingTimeConfig>
        resourceTimeRanges: string|boolean|Partial<ResourceTimeRangesConfig>
        rowCopyPaste: string|boolean|Partial<RowCopyPasteConfig>
        rowReorder: string|boolean|Partial<RowReorderConfig>
        scheduleContext: string|boolean|Partial<ScheduleContextConfig>
        scheduleContextMenu: string|boolean|Partial<ScheduleContextMenuConfig>
        scheduleMenu: string|boolean|Partial<ScheduleMenuConfig>
        scheduleTooltip: string|boolean|Partial<ScheduleTooltipConfig>
        search: string|boolean|Partial<SearchConfig>
        simpleEventEdit: string|boolean|Partial<SimpleEventEditConfig>
        sort: string|boolean|Partial<SortConfig>
        stickyCells: string|boolean|Partial<StickyCellsConfig>
        stickyEvents: string|boolean|Partial<StickyEventsConfig>
        stripe: string|boolean|Partial<StripeConfig>
        summary: string|boolean|Partial<SummaryConfig>
        taskEdit: string|boolean|Partial<SchedulerProTaskEditConfig>
        timeAxisHeaderMenu: string|boolean|Partial<TimeAxisHeaderMenuConfig>
        timeRanges: string|boolean|Partial<TimeRangesConfig>
        tree: string|boolean|Partial<TreeConfig>
    }

    type ResourceHistogramConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        allowCreate: boolean
        allowDropOnEventBar: boolean
        allowOver: boolean
        allowOverlap: boolean
        anchor: boolean
        anchorToTarget: boolean
        animateRemovingRows: boolean
        appendTo: HTMLElement|string
        assignmentStore: SchedulerAssignmentStore|object|Partial<SchedulerAssignmentStoreConfig>
        assignments: SchedulerAssignmentModel[]|object[]|Partial<SchedulerAssignmentModelConfig>[]
        autoAdjustTimeAxis: boolean
        autoClose: boolean
        autoHeight: boolean
        autoShow: boolean
        barMargin: number
        barTextEffortUnit: string
        barTipEffortUnit: string
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        bufferCoef: number
        bufferThreshold: number
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        columnLines: boolean
        columns: object[]|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        contextMenuTriggerEvent: string
        createEventOnDblClick: boolean|object
        creationTooltip: object
        crudManager: object|CrudManager|Partial<CrudManagerConfig>
        crudManagerClass: CrudManager
        data: object[]
        dataset: object
        defaultBindProperty: string
        defaultRegion: string
        defaultResourceImageName: string
        defaults: object
        dependencies: SchedulerDependencyModel[]|object[]|Partial<SchedulerDependencyModelConfig>[]
        dependencyIdField: string
        dependencyStore: SchedulerDependencyStore|object|Partial<SchedulerDependencyStoreConfig>
        descriptionRenderer: Function
        destroyStore: boolean
        destroyStores: boolean
        disableGridRowModelWarning: boolean
        disabled: boolean
        dismissDelay: number
        displayDateFormat: string
        dock: string
        draggable: boolean|object
        durationDisplayPrecision: number|boolean
        effortUnit: string
        emptyText: string
        enableDeleteKey: boolean
        enableEventAnimations: boolean
        enableRecurringEvents: boolean
        enableSticky: boolean
        enableTextSelection: boolean
        enableUndoRedoKeys: boolean
        endDate: Date|string
        endParamName: string
        eventBarTextField: string
        eventBodyTemplate: Function
        eventColor: string
        eventLayout: string
        eventRenderer: Function
        eventRendererThisObj: object
        eventSelectionDisabled: boolean
        eventStore: SchedulerEventStore|object|Partial<SchedulerEventStoreConfig>
        eventStyle: string
        events: SchedulerEventModel[]|object[]|Partial<SchedulerEventModelConfig>[]
        features: Partial<ResourceHistogramFeaturesConfigType>
        fillLastColumn: boolean
        fillTicks: boolean
        fixedRowHeight: boolean
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        forSelector: string
        forceFit: boolean
        fullRowRefresh: boolean
        getBarText: Function
        getBarTip: Function
        getDateConstraints: Function
        getHtml: Function
        getRectClass: Function
        getRowHeight: Function
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideDelay: number
        hideHeaders: boolean
        hideOnDelegateChange: boolean
        hideWhenEmpty: boolean
        highlightPredecessors: boolean
        highlightSuccessors: boolean
        horizontalEventSorterFn: Function
        hoverDelay: number
        html: string
        htmlCls: string|object
        id: string
        infiniteScroll: boolean
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        loadMask: string|object|null
        loadMaskDefaults: object|Mask|Partial<MaskConfig>
        loadMaskError: object|Mask|Partial<MaskConfig>
        loadingMsg: string
        localeClass: Base
        localizableProperties: string[]
        longPressTime: number
        maintainSelectionOnDatasetChange: boolean
        managedEventSizing: boolean
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maxZoomLevel: number
        maximizable: boolean
        maximized: boolean
        milestoneAlign: string
        milestoneCharWidth: number
        milestoneLayoutMode: string
        milestoneTextPosition: string
        minHeight: string|number
        minWidth: string|number
        minZoomLevel: number
        modal: boolean
        mode: string
        monitorResize: boolean
        mouseOffsetX: number
        mouseOffsetY: number
        multiEventSelect: boolean
        namedItems: object
        owner: Widget
        partner: TimelineBase
        passStartEndParameters: boolean
        plugins: Function[]
        positioned: boolean
        preCalculateHeightLimit: number
        preserveFocusOnDatasetChange: boolean
        preserveScrollOnDatasetChange: boolean
        presets: object[]
        preventTooltipOnTouch: boolean
        project: SchedulerProjectModel|object|Partial<SchedulerProjectModelConfig>
        readOnly: boolean
        ref: string
        removeUnassignedEvent: boolean
        resizeToFitIncludesHeader: boolean
        resourceColumns: object
        resourceImageExtension: string
        resourceImagePath: string
        resourceMargin: number
        resourceStore: SchedulerResourceStore|object|Partial<SchedulerResourceStoreConfig>
        resourceTimeRangeStore: ResourceTimeRangeStore|object|Partial<ResourceTimeRangeStoreConfig>
        resourceTimeRanges: ResourceTimeRangeModel[]|object[]|Partial<ResourceTimeRangeModelConfig>[]
        resources: SchedulerResourceModel[]|object[]|Partial<SchedulerResourceModelConfig>[]
        responsiveLevels: object
        ripple: boolean|object
        rootElement: ShadowRoot
        rowHeight: number
        scrollAction: string
        scrollManager: object|ScrollManager|Partial<ScrollManagerConfig>
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        scrollerClass: Scroller
        selectionMode: object
        showAnimation: boolean|object
        showBarText: boolean
        showBarTip: boolean
        showCreationTooltip: boolean
        showDirty: boolean
        showMaxEffort: boolean
        showOnClick: boolean
        showOnHover: boolean
        showRecurringUI: boolean
        showRemoveRowInContextMenu: boolean
        snap: boolean
        snapRelativeToEventStartDate: boolean
        startDate: Date|string
        startParamName: string
        stickyHeaders: boolean
        store: Store|object|Partial<StoreConfig>
        strips: object
        style: string
        subGridConfigs: object
        suppressFit: boolean
        syncMask: string|object|null
        tab: boolean|object
        tag: string
        tbar: object[]|object
        terminalCls: string
        terminalSides: string[]
        textAlign: string
        textContent: boolean
        tickSize: number
        timeAxis: object|TimeAxis|Partial<TimeAxisConfig>
        timeRangeStore: Store|object|Partial<StoreConfig>
        timeRanges: TimeSpan[]|object[]|Partial<TimeSpanConfig>[]
        title: string
        tools: object
        tooltip: string|object
        transitionDuration: number
        trapFocus: boolean
        triggerSelectionChangeOnRemove: boolean
        useInitialAnimation: boolean|string
        verticalTimeAxisColumn: object
        viewPreset: string|object
        visibleDate: Date|object
        visibleZoomFactor: number
        weekStartDay: number
        weight: number
        width: string|number
        workingTime: object
        x: number
        y: number
        zoomKeepsOriginalTimespan: boolean
        zoomOnMouseWheel: boolean
        zoomOnTimeAxisDoubleClick: boolean
    }

    export class ResourceHistogram extends SchedulerProBase {
        features: ResourceHistogramFeaturesType
        constructor(config?: Partial<ResourceHistogramConfig>);
    }

    type SchedulerProFeaturesType = {
        cellEdit: GridCellEdit
        cellMenu: CellMenu
        cellTooltip: CellTooltip
        columnAutoWidth: ColumnAutoWidth
        columnDragToolbar: ColumnDragToolbar
        columnLines: ColumnLines
        columnPicker: ColumnPicker
        columnReorder: ColumnReorder
        columnResize: ColumnResize
        contextMenu: ContextMenu
        dependencies: SchedulerDependencies
        dependencyEdit: SchedulerDependencyEdit
        eventContextMenu: EventContextMenu
        eventCopyPaste: EventCopyPaste
        eventDrag: EventDrag
        eventDragCreate: EventDragCreate
        eventDragSelect: EventDragSelect
        eventEdit: EventEdit
        eventFilter: EventFilter
        eventMenu: EventMenu
        eventResize: EventResize
        eventTooltip: EventTooltip
        excelExporter: ExcelExporter
        filter: Filter
        filterBar: FilterBar
        group: Group
        groupSummary: GroupSummary
        headerContextMenu: HeaderContextMenu
        headerMenu: HeaderMenu
        headerZoom: HeaderZoom
        labels: SchedulerLabels
        nonWorkingTime: NonWorkingTime
        pan: Pan
        pdfExport: SchedulerPdfExport
        percentBar: PercentBar
        quickFind: QuickFind
        regionResize: RegionResize
        resourceNonWorkingTime: ResourceNonWorkingTime
        resourceTimeRanges: ResourceTimeRanges
        rowCopyPaste: RowCopyPaste
        rowReorder: RowReorder
        scheduleContext: ScheduleContext
        scheduleContextMenu: ScheduleContextMenu
        scheduleMenu: ScheduleMenu
        scheduleTooltip: ScheduleTooltip
        search: Search
        simpleEventEdit: SimpleEventEdit
        sort: Sort
        stickyCells: StickyCells
        stickyEvents: StickyEvents
        stripe: Stripe
        summary: Summary
        taskEdit: SchedulerProTaskEdit
        timeAxisHeaderMenu: TimeAxisHeaderMenu
        timeRanges: TimeRanges
        tree: Tree
    }

    type SchedulerProFeaturesConfigType = {
        cellEdit: string|boolean|Partial<GridCellEditConfig>
        cellMenu: string|boolean|Partial<CellMenuConfig>
        cellTooltip: string|boolean|Partial<CellTooltipConfig>
        columnAutoWidth: string|boolean|Partial<ColumnAutoWidthConfig>
        columnDragToolbar: string|boolean|Partial<ColumnDragToolbarConfig>
        columnLines: string|boolean|Partial<ColumnLinesConfig>
        columnPicker: string|boolean|Partial<ColumnPickerConfig>
        columnReorder: string|boolean|Partial<ColumnReorderConfig>
        columnResize: string|boolean|Partial<ColumnResizeConfig>
        contextMenu: string|boolean|Partial<ContextMenuConfig>
        dependencies: string|boolean|Partial<SchedulerDependenciesConfig>
        dependencyEdit: string|boolean|Partial<SchedulerDependencyEditConfig>
        eventContextMenu: string|boolean|Partial<EventContextMenuConfig>
        eventCopyPaste: string|boolean|Partial<EventCopyPasteConfig>
        eventDrag: string|boolean|Partial<EventDragConfig>
        eventDragCreate: string|boolean|Partial<EventDragCreateConfig>
        eventDragSelect: string|boolean|Partial<EventDragSelectConfig>
        eventEdit: string|boolean|Partial<EventEditConfig>
        eventFilter: string|boolean|Partial<EventFilterConfig>
        eventMenu: string|boolean|Partial<EventMenuConfig>
        eventResize: string|boolean|Partial<EventResizeConfig>
        eventTooltip: string|boolean|Partial<EventTooltipConfig>
        excelExporter: string|boolean|Partial<ExcelExporterConfig>
        filter: string|boolean|Partial<FilterConfig>
        filterBar: string|boolean|Partial<FilterBarConfig>
        group: string|boolean|Partial<GroupConfig>
        groupSummary: string|boolean|Partial<GroupSummaryConfig>
        headerContextMenu: string|boolean|Partial<HeaderContextMenuConfig>
        headerMenu: string|boolean|Partial<HeaderMenuConfig>
        headerZoom: string|boolean|Partial<HeaderZoomConfig>
        labels: string|boolean|Partial<SchedulerLabelsConfig>
        nonWorkingTime: string|boolean|Partial<NonWorkingTimeConfig>
        pan: string|boolean|Partial<PanConfig>
        pdfExport: string|boolean|Partial<SchedulerPdfExportConfig>
        percentBar: string|boolean|Partial<PercentBarConfig>
        quickFind: string|boolean|Partial<QuickFindConfig>
        regionResize: string|boolean|Partial<RegionResizeConfig>
        resourceNonWorkingTime: string|boolean|Partial<ResourceNonWorkingTimeConfig>
        resourceTimeRanges: string|boolean|Partial<ResourceTimeRangesConfig>
        rowCopyPaste: string|boolean|Partial<RowCopyPasteConfig>
        rowReorder: string|boolean|Partial<RowReorderConfig>
        scheduleContext: string|boolean|Partial<ScheduleContextConfig>
        scheduleContextMenu: string|boolean|Partial<ScheduleContextMenuConfig>
        scheduleMenu: string|boolean|Partial<ScheduleMenuConfig>
        scheduleTooltip: string|boolean|Partial<ScheduleTooltipConfig>
        search: string|boolean|Partial<SearchConfig>
        simpleEventEdit: string|boolean|Partial<SimpleEventEditConfig>
        sort: string|boolean|Partial<SortConfig>
        stickyCells: string|boolean|Partial<StickyCellsConfig>
        stickyEvents: string|boolean|Partial<StickyEventsConfig>
        stripe: string|boolean|Partial<StripeConfig>
        summary: string|boolean|Partial<SummaryConfig>
        taskEdit: string|boolean|Partial<SchedulerProTaskEditConfig>
        timeAxisHeaderMenu: string|boolean|Partial<TimeAxisHeaderMenuConfig>
        timeRanges: string|boolean|Partial<TimeRangesConfig>
        tree: string|boolean|Partial<TreeConfig>
    }

    type SchedulerProConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        allowCreate: boolean
        allowDropOnEventBar: boolean
        allowOver: boolean
        allowOverlap: boolean
        anchor: boolean
        anchorToTarget: boolean
        animateRemovingRows: boolean
        appendTo: HTMLElement|string
        assignmentStore: SchedulerAssignmentStore|object|Partial<SchedulerAssignmentStoreConfig>
        assignments: SchedulerAssignmentModel[]|object[]|Partial<SchedulerAssignmentModelConfig>[]
        autoAdjustTimeAxis: boolean
        autoClose: boolean
        autoHeight: boolean
        autoShow: boolean
        barMargin: number
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        bufferCoef: number
        bufferThreshold: number
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        columnLines: boolean
        columns: object[]|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        contextMenuTriggerEvent: string
        createEventOnDblClick: boolean|object
        creationTooltip: object
        crudManager: object|CrudManager|Partial<CrudManagerConfig>
        crudManagerClass: CrudManager
        data: object[]
        dataset: object
        defaultBindProperty: string
        defaultRegion: string
        defaultResourceImageName: string
        defaults: object
        dependencies: SchedulerDependencyModel[]|object[]|Partial<SchedulerDependencyModelConfig>[]
        dependencyIdField: string
        dependencyStore: SchedulerDependencyStore|object|Partial<SchedulerDependencyStoreConfig>
        descriptionRenderer: Function
        destroyStore: boolean
        destroyStores: boolean
        disableGridRowModelWarning: boolean
        disabled: boolean
        dismissDelay: number
        displayDateFormat: string
        dock: string
        draggable: boolean|object
        durationDisplayPrecision: number|boolean
        emptyText: string
        enableDeleteKey: boolean
        enableEventAnimations: boolean
        enableRecurringEvents: boolean
        enableSticky: boolean
        enableTextSelection: boolean
        enableUndoRedoKeys: boolean
        endDate: Date|string
        endParamName: string
        eventBarTextField: string
        eventBodyTemplate: Function
        eventColor: string
        eventLayout: string
        eventRenderer: Function
        eventRendererThisObj: object
        eventSelectionDisabled: boolean
        eventStore: SchedulerEventStore|object|Partial<SchedulerEventStoreConfig>
        eventStyle: string
        events: SchedulerEventModel[]|object[]|Partial<SchedulerEventModelConfig>[]
        features: Partial<SchedulerProFeaturesConfigType>
        fillLastColumn: boolean
        fillTicks: boolean
        fixedRowHeight: boolean
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        forSelector: string
        forceFit: boolean
        fullRowRefresh: boolean
        getDateConstraints: Function
        getHtml: Function
        getRowHeight: Function
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideDelay: number
        hideHeaders: boolean
        hideOnDelegateChange: boolean
        hideWhenEmpty: boolean
        highlightPredecessors: boolean
        highlightSuccessors: boolean
        horizontalEventSorterFn: Function
        hoverDelay: number
        html: string
        htmlCls: string|object
        id: string
        infiniteScroll: boolean
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        loadMask: string|object|null
        loadMaskDefaults: object|Mask|Partial<MaskConfig>
        loadMaskError: object|Mask|Partial<MaskConfig>
        loadingMsg: string
        localeClass: Base
        localizableProperties: string[]
        longPressTime: number
        maintainSelectionOnDatasetChange: boolean
        managedEventSizing: boolean
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maxZoomLevel: number
        maximizable: boolean
        maximized: boolean
        milestoneAlign: string
        milestoneCharWidth: number
        milestoneLayoutMode: string
        milestoneTextPosition: string
        minHeight: string|number
        minWidth: string|number
        minZoomLevel: number
        modal: boolean
        mode: string
        monitorResize: boolean
        mouseOffsetX: number
        mouseOffsetY: number
        multiEventSelect: boolean
        namedItems: object
        owner: Widget
        partner: TimelineBase
        passStartEndParameters: boolean
        plugins: Function[]
        positioned: boolean
        preCalculateHeightLimit: number
        preserveFocusOnDatasetChange: boolean
        preserveScrollOnDatasetChange: boolean
        presets: object[]
        preventTooltipOnTouch: boolean
        project: SchedulerProjectModel|object|Partial<SchedulerProjectModelConfig>
        readOnly: boolean
        ref: string
        removeUnassignedEvent: boolean
        resizeToFitIncludesHeader: boolean
        resourceColumns: object
        resourceImageExtension: string
        resourceImagePath: string
        resourceMargin: number
        resourceStore: SchedulerResourceStore|object|Partial<SchedulerResourceStoreConfig>
        resourceTimeRangeStore: ResourceTimeRangeStore|object|Partial<ResourceTimeRangeStoreConfig>
        resourceTimeRanges: ResourceTimeRangeModel[]|object[]|Partial<ResourceTimeRangeModelConfig>[]
        resources: SchedulerResourceModel[]|object[]|Partial<SchedulerResourceModelConfig>[]
        responsiveLevels: object
        ripple: boolean|object
        rootElement: ShadowRoot
        rowHeight: number
        scrollAction: string
        scrollManager: object|ScrollManager|Partial<ScrollManagerConfig>
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        scrollerClass: Scroller
        selectionMode: object
        showAnimation: boolean|object
        showCreationTooltip: boolean
        showDirty: boolean
        showOnClick: boolean
        showOnHover: boolean
        showRecurringUI: boolean
        showRemoveRowInContextMenu: boolean
        snap: boolean
        snapRelativeToEventStartDate: boolean
        startDate: Date|string
        startParamName: string
        stickyHeaders: boolean
        store: Store|object|Partial<StoreConfig>
        strips: object
        style: string
        subGridConfigs: object
        suppressFit: boolean
        syncMask: string|object|null
        tab: boolean|object
        tag: string
        tbar: object[]|object
        terminalCls: string
        terminalSides: string[]
        textAlign: string
        textContent: boolean
        tickSize: number
        timeAxis: object|TimeAxis|Partial<TimeAxisConfig>
        timeRangeStore: Store|object|Partial<StoreConfig>
        timeRanges: TimeSpan[]|object[]|Partial<TimeSpanConfig>[]
        title: string
        tools: object
        tooltip: string|object
        transitionDuration: number
        trapFocus: boolean
        triggerSelectionChangeOnRemove: boolean
        useInitialAnimation: boolean|string
        verticalTimeAxisColumn: object
        viewPreset: string|object
        visibleDate: Date|object
        visibleZoomFactor: number
        weekStartDay: number
        weight: number
        width: string|number
        workingTime: object
        x: number
        y: number
        zoomKeepsOriginalTimespan: boolean
        zoomOnMouseWheel: boolean
        zoomOnTimeAxisDoubleClick: boolean
    }

    export class SchedulerPro extends SchedulerProBase {
        features: SchedulerProFeaturesType
        constructor(config?: Partial<SchedulerProConfig>);
    }

    type SchedulerProBaseFeaturesType = {
        cellEdit: GridCellEdit
        cellMenu: CellMenu
        cellTooltip: CellTooltip
        columnAutoWidth: ColumnAutoWidth
        columnDragToolbar: ColumnDragToolbar
        columnLines: ColumnLines
        columnPicker: ColumnPicker
        columnReorder: ColumnReorder
        columnResize: ColumnResize
        contextMenu: ContextMenu
        dependencies: SchedulerDependencies
        dependencyEdit: SchedulerDependencyEdit
        eventContextMenu: EventContextMenu
        eventCopyPaste: EventCopyPaste
        eventDrag: EventDrag
        eventDragCreate: EventDragCreate
        eventDragSelect: EventDragSelect
        eventEdit: EventEdit
        eventFilter: EventFilter
        eventMenu: EventMenu
        eventResize: EventResize
        eventTooltip: EventTooltip
        excelExporter: ExcelExporter
        filter: Filter
        filterBar: FilterBar
        group: Group
        groupSummary: GroupSummary
        headerContextMenu: HeaderContextMenu
        headerMenu: HeaderMenu
        headerZoom: HeaderZoom
        labels: SchedulerLabels
        nonWorkingTime: NonWorkingTime
        pan: Pan
        pdfExport: SchedulerPdfExport
        percentBar: PercentBar
        quickFind: QuickFind
        regionResize: RegionResize
        resourceNonWorkingTime: ResourceNonWorkingTime
        resourceTimeRanges: ResourceTimeRanges
        rowCopyPaste: RowCopyPaste
        rowReorder: RowReorder
        scheduleContext: ScheduleContext
        scheduleContextMenu: ScheduleContextMenu
        scheduleMenu: ScheduleMenu
        scheduleTooltip: ScheduleTooltip
        search: Search
        simpleEventEdit: SimpleEventEdit
        sort: Sort
        stickyCells: StickyCells
        stickyEvents: StickyEvents
        stripe: Stripe
        summary: Summary
        taskEdit: SchedulerProTaskEdit
        timeAxisHeaderMenu: TimeAxisHeaderMenu
        timeRanges: TimeRanges
        tree: Tree
    }

    type SchedulerProBaseFeaturesConfigType = {
        cellEdit: string|boolean|Partial<GridCellEditConfig>
        cellMenu: string|boolean|Partial<CellMenuConfig>
        cellTooltip: string|boolean|Partial<CellTooltipConfig>
        columnAutoWidth: string|boolean|Partial<ColumnAutoWidthConfig>
        columnDragToolbar: string|boolean|Partial<ColumnDragToolbarConfig>
        columnLines: string|boolean|Partial<ColumnLinesConfig>
        columnPicker: string|boolean|Partial<ColumnPickerConfig>
        columnReorder: string|boolean|Partial<ColumnReorderConfig>
        columnResize: string|boolean|Partial<ColumnResizeConfig>
        contextMenu: string|boolean|Partial<ContextMenuConfig>
        dependencies: string|boolean|Partial<SchedulerDependenciesConfig>
        dependencyEdit: string|boolean|Partial<SchedulerDependencyEditConfig>
        eventContextMenu: string|boolean|Partial<EventContextMenuConfig>
        eventCopyPaste: string|boolean|Partial<EventCopyPasteConfig>
        eventDrag: string|boolean|Partial<EventDragConfig>
        eventDragCreate: string|boolean|Partial<EventDragCreateConfig>
        eventDragSelect: string|boolean|Partial<EventDragSelectConfig>
        eventEdit: string|boolean|Partial<EventEditConfig>
        eventFilter: string|boolean|Partial<EventFilterConfig>
        eventMenu: string|boolean|Partial<EventMenuConfig>
        eventResize: string|boolean|Partial<EventResizeConfig>
        eventTooltip: string|boolean|Partial<EventTooltipConfig>
        excelExporter: string|boolean|Partial<ExcelExporterConfig>
        filter: string|boolean|Partial<FilterConfig>
        filterBar: string|boolean|Partial<FilterBarConfig>
        group: string|boolean|Partial<GroupConfig>
        groupSummary: string|boolean|Partial<GroupSummaryConfig>
        headerContextMenu: string|boolean|Partial<HeaderContextMenuConfig>
        headerMenu: string|boolean|Partial<HeaderMenuConfig>
        headerZoom: string|boolean|Partial<HeaderZoomConfig>
        labels: string|boolean|Partial<SchedulerLabelsConfig>
        nonWorkingTime: string|boolean|Partial<NonWorkingTimeConfig>
        pan: string|boolean|Partial<PanConfig>
        pdfExport: string|boolean|Partial<SchedulerPdfExportConfig>
        percentBar: string|boolean|Partial<PercentBarConfig>
        quickFind: string|boolean|Partial<QuickFindConfig>
        regionResize: string|boolean|Partial<RegionResizeConfig>
        resourceNonWorkingTime: string|boolean|Partial<ResourceNonWorkingTimeConfig>
        resourceTimeRanges: string|boolean|Partial<ResourceTimeRangesConfig>
        rowCopyPaste: string|boolean|Partial<RowCopyPasteConfig>
        rowReorder: string|boolean|Partial<RowReorderConfig>
        scheduleContext: string|boolean|Partial<ScheduleContextConfig>
        scheduleContextMenu: string|boolean|Partial<ScheduleContextMenuConfig>
        scheduleMenu: string|boolean|Partial<ScheduleMenuConfig>
        scheduleTooltip: string|boolean|Partial<ScheduleTooltipConfig>
        search: string|boolean|Partial<SearchConfig>
        simpleEventEdit: string|boolean|Partial<SimpleEventEditConfig>
        sort: string|boolean|Partial<SortConfig>
        stickyCells: string|boolean|Partial<StickyCellsConfig>
        stickyEvents: string|boolean|Partial<StickyEventsConfig>
        stripe: string|boolean|Partial<StripeConfig>
        summary: string|boolean|Partial<SummaryConfig>
        taskEdit: string|boolean|Partial<SchedulerProTaskEditConfig>
        timeAxisHeaderMenu: string|boolean|Partial<TimeAxisHeaderMenuConfig>
        timeRanges: string|boolean|Partial<TimeRangesConfig>
        tree: string|boolean|Partial<TreeConfig>
    }

    type SchedulerProBaseConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        allowCreate: boolean
        allowDropOnEventBar: boolean
        allowOver: boolean
        allowOverlap: boolean
        anchor: boolean
        anchorToTarget: boolean
        animateRemovingRows: boolean
        appendTo: HTMLElement|string
        assignmentStore: SchedulerAssignmentStore|object|Partial<SchedulerAssignmentStoreConfig>
        assignments: SchedulerAssignmentModel[]|object[]|Partial<SchedulerAssignmentModelConfig>[]
        autoAdjustTimeAxis: boolean
        autoClose: boolean
        autoHeight: boolean
        autoShow: boolean
        barMargin: number
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        bufferCoef: number
        bufferThreshold: number
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        columnLines: boolean
        columns: object[]|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        contextMenuTriggerEvent: string
        createEventOnDblClick: boolean|object
        creationTooltip: object
        crudManager: object|CrudManager|Partial<CrudManagerConfig>
        crudManagerClass: CrudManager
        data: object[]
        dataset: object
        defaultBindProperty: string
        defaultRegion: string
        defaultResourceImageName: string
        defaults: object
        dependencies: SchedulerDependencyModel[]|object[]|Partial<SchedulerDependencyModelConfig>[]
        dependencyIdField: string
        dependencyStore: SchedulerDependencyStore|object|Partial<SchedulerDependencyStoreConfig>
        descriptionRenderer: Function
        destroyStore: boolean
        destroyStores: boolean
        disableGridRowModelWarning: boolean
        disabled: boolean
        dismissDelay: number
        displayDateFormat: string
        dock: string
        draggable: boolean|object
        durationDisplayPrecision: number|boolean
        emptyText: string
        enableDeleteKey: boolean
        enableEventAnimations: boolean
        enableRecurringEvents: boolean
        enableSticky: boolean
        enableTextSelection: boolean
        enableUndoRedoKeys: boolean
        endDate: Date|string
        endParamName: string
        eventBarTextField: string
        eventBodyTemplate: Function
        eventColor: string
        eventLayout: string
        eventRenderer: Function
        eventRendererThisObj: object
        eventSelectionDisabled: boolean
        eventStore: SchedulerEventStore|object|Partial<SchedulerEventStoreConfig>
        eventStyle: string
        events: SchedulerEventModel[]|object[]|Partial<SchedulerEventModelConfig>[]
        features: Partial<SchedulerProBaseFeaturesConfigType>
        fillLastColumn: boolean
        fillTicks: boolean
        fixedRowHeight: boolean
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        forSelector: string
        forceFit: boolean
        fullRowRefresh: boolean
        getDateConstraints: Function
        getHtml: Function
        getRowHeight: Function
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideDelay: number
        hideHeaders: boolean
        hideOnDelegateChange: boolean
        hideWhenEmpty: boolean
        highlightPredecessors: boolean
        highlightSuccessors: boolean
        horizontalEventSorterFn: Function
        hoverDelay: number
        html: string
        htmlCls: string|object
        id: string
        infiniteScroll: boolean
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        loadMask: string|object|null
        loadMaskDefaults: object|Mask|Partial<MaskConfig>
        loadMaskError: object|Mask|Partial<MaskConfig>
        loadingMsg: string
        localeClass: Base
        localizableProperties: string[]
        longPressTime: number
        maintainSelectionOnDatasetChange: boolean
        managedEventSizing: boolean
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maxZoomLevel: number
        maximizable: boolean
        maximized: boolean
        milestoneAlign: string
        milestoneCharWidth: number
        milestoneLayoutMode: string
        milestoneTextPosition: string
        minHeight: string|number
        minWidth: string|number
        minZoomLevel: number
        modal: boolean
        mode: string
        monitorResize: boolean
        mouseOffsetX: number
        mouseOffsetY: number
        multiEventSelect: boolean
        namedItems: object
        owner: Widget
        partner: TimelineBase
        passStartEndParameters: boolean
        plugins: Function[]
        positioned: boolean
        preCalculateHeightLimit: number
        preserveFocusOnDatasetChange: boolean
        preserveScrollOnDatasetChange: boolean
        presets: object[]
        preventTooltipOnTouch: boolean
        project: SchedulerProjectModel|object|Partial<SchedulerProjectModelConfig>
        readOnly: boolean
        ref: string
        removeUnassignedEvent: boolean
        resizeToFitIncludesHeader: boolean
        resourceColumns: object
        resourceImageExtension: string
        resourceImagePath: string
        resourceMargin: number
        resourceStore: SchedulerResourceStore|object|Partial<SchedulerResourceStoreConfig>
        resourceTimeRangeStore: ResourceTimeRangeStore|object|Partial<ResourceTimeRangeStoreConfig>
        resourceTimeRanges: ResourceTimeRangeModel[]|object[]|Partial<ResourceTimeRangeModelConfig>[]
        resources: SchedulerResourceModel[]|object[]|Partial<SchedulerResourceModelConfig>[]
        responsiveLevels: object
        ripple: boolean|object
        rootElement: ShadowRoot
        rowHeight: number
        scrollAction: string
        scrollManager: object|ScrollManager|Partial<ScrollManagerConfig>
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        scrollerClass: Scroller
        selectionMode: object
        showAnimation: boolean|object
        showCreationTooltip: boolean
        showDirty: boolean
        showOnClick: boolean
        showOnHover: boolean
        showRecurringUI: boolean
        showRemoveRowInContextMenu: boolean
        snap: boolean
        snapRelativeToEventStartDate: boolean
        startDate: Date|string
        startParamName: string
        stickyHeaders: boolean
        store: Store|object|Partial<StoreConfig>
        strips: object
        style: string
        subGridConfigs: object
        suppressFit: boolean
        syncMask: string|object|null
        tab: boolean|object
        tag: string
        tbar: object[]|object
        terminalCls: string
        terminalSides: string[]
        textAlign: string
        textContent: boolean
        tickSize: number
        timeAxis: object|TimeAxis|Partial<TimeAxisConfig>
        timeRangeStore: Store|object|Partial<StoreConfig>
        timeRanges: TimeSpan[]|object[]|Partial<TimeSpanConfig>[]
        title: string
        tools: object
        tooltip: string|object
        transitionDuration: number
        trapFocus: boolean
        triggerSelectionChangeOnRemove: boolean
        useInitialAnimation: boolean|string
        verticalTimeAxisColumn: object
        viewPreset: string|object
        visibleDate: Date|object
        visibleZoomFactor: number
        weekStartDay: number
        weight: number
        width: string|number
        workingTime: object
        x: number
        y: number
        zoomKeepsOriginalTimespan: boolean
        zoomOnMouseWheel: boolean
        zoomOnTimeAxisDoubleClick: boolean
        onAfterEventSave: Function
        onAfterTaskSave: Function
        onBeforeDestroy: Function
        onBeforeEventDelete: Function
        onBeforeEventResize: Function
        onBeforeEventResizeFinalize: Function
        onBeforeEventSave: Function
        onBeforeTaskDelete: Function
        onBeforeTaskEdit: Function
        onBeforeTaskEditShow: Function
        onBeforeTaskSave: Function
        onCatchAll: Function
        onDestroy: Function
        onEventPartialResize: Function
        onEventResizeEnd: Function
        onEventResizeStart: Function
    }

    export class SchedulerProBase extends SchedulerBase {
        localeManager: typeof LocaleManager
        features: SchedulerProBaseFeaturesType
        onAfterEventSave: Function
        onAfterTaskSave: Function
        onBeforeDestroy: Function
        onBeforeEventDelete: Function
        onBeforeEventResize: Function
        onBeforeEventResizeFinalize: Function
        onBeforeEventSave: Function
        onBeforeTaskDelete: Function
        onBeforeTaskEdit: Function
        onBeforeTaskEditShow: Function
        onBeforeTaskSave: Function
        onCatchAll: Function
        onDestroy: Function
        onEventPartialResize: Function
        onEventResizeEnd: Function
        onEventResizeStart: Function
        constructor(config?: Partial<SchedulerProBaseConfig>);
        static optionalL(text: string, templateData?: object): string;
        L(text: string, templateData?: object): string;
        addListener(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        hasListener(eventName: string): boolean;
        on(config: object|string, thisObj?: object|Function, oldThisObj?: object): Function;
        relayAll(through: Events, prefix: string, transformCase?: boolean): void;
        removeAllListeners(): void;
        removeListener(config: object, thisObj: object): void;
        resumeEvents(): void;
        suspendEvents(queue?: boolean): void;
        trigger(eventName: string, param?: object): boolean|Promise<any>;
        un(config: object, thisObj?: object): void;
        updateLocalization(): void;
    }

    type CalendarFieldConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoComplete: string
        autoExpand: boolean
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        caseSensitive: boolean
        centered: boolean
        chipView: object
        clearTextOnPickerHide: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        displayField: string
        displayValueRenderer: Function
        dock: string
        draggable: boolean|object
        editable: boolean
        emptyText: string
        encodeFilterParams: Function
        filterOnEnter: boolean
        filterOperator: string
        filterParamName: string
        filterSelected: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hidePickerOnSelect: boolean
        hideTrigger: boolean
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        items: object[]|string[]|object
        keyStrokeChangeDelay: number
        keyStrokeFilterDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listCls: string
        listItemTpl: Function
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        minChars: number
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        multiSelect: boolean
        name: string
        overlayAnchor: boolean
        owner: Widget
        picker: object
        pickerAlignElement: string
        pickerWidth: number
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        primaryFilter: object
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        store: SchedulerProCalendarManagerStore
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggerAction: string
        triggers: object
        validateFilter: boolean
        value: string|number[]|string[]
        valueField: string
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class CalendarField extends ModelCombo {
        constructor(config?: Partial<CalendarFieldConfig>);
    }

    type ConstraintTypePickerConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoComplete: string
        autoExpand: boolean
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        caseSensitive: boolean
        centered: boolean
        chipView: object
        clearTextOnPickerHide: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        displayField: string
        displayValueRenderer: Function
        dock: string
        draggable: boolean|object
        editable: boolean
        emptyText: string
        encodeFilterParams: Function
        filterOnEnter: boolean
        filterOperator: string
        filterParamName: string
        filterSelected: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hidePickerOnSelect: boolean
        hideTrigger: boolean
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        items: object[]|string[]|object
        keyStrokeChangeDelay: number
        keyStrokeFilterDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listCls: string
        listItemTpl: Function
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        minChars: number
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        multiSelect: boolean
        name: string
        overlayAnchor: boolean
        owner: Widget
        picker: object
        pickerAlignElement: string
        pickerWidth: number
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        primaryFilter: object
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        store: Store
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggerAction: string
        triggers: object
        validateFilter: boolean
        value: string|number[]|string[]
        valueField: string
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class ConstraintTypePicker extends Combo {
        constructor(config?: Partial<ConstraintTypePickerConfig>);
    }

    type DependencyTypePickerConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoComplete: string
        autoExpand: boolean
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        caseSensitive: boolean
        centered: boolean
        chipView: object
        clearTextOnPickerHide: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        displayField: string
        displayValueRenderer: Function
        dock: string
        draggable: boolean|object
        editable: boolean
        emptyText: string
        encodeFilterParams: Function
        filterOnEnter: boolean
        filterOperator: string
        filterParamName: string
        filterSelected: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hidePickerOnSelect: boolean
        hideTrigger: boolean
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        items: object[]|string[]|object
        keyStrokeChangeDelay: number
        keyStrokeFilterDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listCls: string
        listItemTpl: Function
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        minChars: number
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        multiSelect: boolean
        name: string
        overlayAnchor: boolean
        owner: Widget
        picker: object
        pickerAlignElement: string
        pickerWidth: number
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        primaryFilter: object
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        store: Store
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggerAction: string
        triggers: object
        validateFilter: boolean
        value: string|number[]|string[]
        valueField: string
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class DependencyTypePicker extends Combo {
        constructor(config?: Partial<DependencyTypePickerConfig>);
    }

    type EffortFieldConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        allowNegative: boolean
        allowedUnits: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoComplete: string
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        centered: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        decimalPrecision: number
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        editable: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        keyStrokeChangeDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        magnitude: number
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        max: string
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        min: string
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        name: string
        owner: Widget
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        step: number
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggers: object
        unit: string
        useAbbreviation: boolean
        value: object|string
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class EffortField extends DurationField {
        constructor(config?: Partial<EffortFieldConfig>);
    }

    type EndDateFieldConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoComplete: string
        autoExpand: boolean
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        centered: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        editable: boolean
        eventRecord: EventModel
        flex: number|string
        floating: boolean
        format: string
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        keepTime: boolean|Date|string
        keyStrokeChangeDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        max: string|Date
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        min: string|Date
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        name: string
        owner: Widget
        picker: object
        pickerAlignElement: string
        pickerFormat: string
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        project: SchedulerProProjectModel
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        step: string|number|object
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggers: object
        value: string|Date
        weekStartDay: number
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class EndDateField extends DateField {
        constructor(config?: Partial<EndDateFieldConfig>);
    }

    type GanttTaskEditorConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoShow: boolean
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        calculateMask: string|null
        calculateMaskDelay: number|null
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        dependencyIdField: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        durationDisplayPrecision: number
        extraItems: object
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maximizable: boolean
        maximized: boolean
        minHeight: string|number
        minWidth: string|number
        modal: boolean
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showOnClick: boolean
        strips: object
        style: string
        tab: boolean|object
        tabsConfig: object
        tag: string
        tbar: object[]|object
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        trapFocus: boolean
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class GanttTaskEditor extends TaskEditorBase {
        constructor(config?: Partial<GanttTaskEditorConfig>);
    }

    type ModelComboConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoComplete: string
        autoExpand: boolean
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        caseSensitive: boolean
        centered: boolean
        chipView: object
        clearTextOnPickerHide: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        displayField: string
        displayValueRenderer: Function
        dock: string
        draggable: boolean|object
        editable: boolean
        emptyText: string
        encodeFilterParams: Function
        filterOnEnter: boolean
        filterOperator: string
        filterParamName: string
        filterSelected: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hidePickerOnSelect: boolean
        hideTrigger: boolean
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        items: object[]|string[]|object
        keyStrokeChangeDelay: number
        keyStrokeFilterDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listCls: string
        listItemTpl: Function
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        minChars: number
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        multiSelect: boolean
        name: string
        overlayAnchor: boolean
        owner: Widget
        picker: object
        pickerAlignElement: string
        pickerWidth: number
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        primaryFilter: object
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        store: Store
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggerAction: string
        triggers: object
        validateFilter: boolean
        value: string|number[]|string[]
        valueField: string
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class ModelCombo extends Combo {
        constructor(config?: Partial<ModelComboConfig>);
    }

    type SchedulerTaskEditorConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoShow: boolean
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        calculateMask: string|null
        calculateMaskDelay: number|null
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        dependencyIdField: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        durationDisplayPrecision: number
        extraItems: object
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maximizable: boolean
        maximized: boolean
        minHeight: string|number
        minWidth: string|number
        modal: boolean
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showOnClick: boolean
        strips: object
        style: string
        tab: boolean|object
        tabsConfig: object
        tag: string
        tbar: object[]|object
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        trapFocus: boolean
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class SchedulerTaskEditor extends TaskEditorBase {
        constructor(config?: Partial<SchedulerTaskEditorConfig>);
    }

    type SchedulingModePickerConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoComplete: string
        autoExpand: boolean
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        caseSensitive: boolean
        centered: boolean
        chipView: object
        clearTextOnPickerHide: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        displayField: string
        displayValueRenderer: Function
        dock: string
        draggable: boolean|object
        editable: boolean
        emptyText: string
        encodeFilterParams: Function
        filterOnEnter: boolean
        filterOperator: string
        filterParamName: string
        filterSelected: boolean
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hidePickerOnSelect: boolean
        hideTrigger: boolean
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        items: object[]|string[]|object
        keyStrokeChangeDelay: number
        keyStrokeFilterDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listCls: string
        listItemTpl: Function
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        minChars: number
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        multiSelect: boolean
        name: string
        overlayAnchor: boolean
        owner: Widget
        picker: object
        pickerAlignElement: string
        pickerWidth: number
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        primaryFilter: object
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        store: Store
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggerAction: string
        triggers: object
        validateFilter: boolean
        value: string|number[]|string[]
        valueField: string
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class SchedulingModePicker extends Combo {
        constructor(config?: Partial<SchedulingModePickerConfig>);
    }

    type StartDateFieldConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoComplete: string
        autoExpand: boolean
        autoSelect: boolean
        badge: string
        bubbleEvents: object
        centered: boolean
        clearable: boolean|object
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        editable: boolean
        eventRecord: EventModel
        flex: number|string
        floating: boolean
        format: string
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        highlightExternalChange: boolean
        hint: string|Function
        hintHtml: string|Function
        html: string
        htmlCls: string|object
        id: string
        inputAlign: string
        inputAttributes: object
        inputWidth: string|number
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        keepTime: boolean|Date|string
        keyStrokeChangeDelay: number
        label: string
        labelCls: string|object
        labelPosition: string
        labelWidth: string|number
        labels: object
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        max: string|Date
        maxHeight: string|number
        maxLength: number
        maxWidth: string|number
        min: string|Date
        minHeight: string|number
        minLength: number
        minWidth: string|number
        monitorResize: boolean
        name: string
        owner: Widget
        picker: object
        pickerAlignElement: string
        pickerFormat: string
        placeholder: string
        positioned: boolean
        preventTooltipOnTouch: boolean
        project: SchedulerProProjectModel
        readOnly: boolean
        ref: string
        required: boolean
        revertOnEscape: boolean
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        step: string|number|object
        style: string
        tab: boolean|object
        tabIndex: number
        tag: string
        textAlign: string
        title: string
        tooltip: string|object
        triggers: object
        value: string|Date
        weekStartDay: number
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class StartDateField extends DateField {
        constructor(config?: Partial<StartDateFieldConfig>);
    }

    type TaskEditorBaseConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        autoClose: boolean
        autoShow: boolean
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        calculateMask: string|null
        calculateMaskDelay: number|null
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        dependencyIdField: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        durationDisplayPrecision: number
        extraItems: object
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maximizable: boolean
        maximized: boolean
        minHeight: string|number
        minWidth: string|number
        modal: boolean
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        showOnClick: boolean
        strips: object
        style: string
        tab: boolean|object
        tabsConfig: object
        tag: string
        tbar: object[]|object
        textAlign: string
        textContent: boolean
        title: string
        tools: object
        tooltip: string|object
        trapFocus: boolean
        weight: number
        width: string|number
        x: number
        y: number
    }

    export abstract class TaskEditorBase extends Popup {
        constructor(config?: Partial<TaskEditorBaseConfig>);
        loadEvent(record: EventModel): void;
    }

    type TimelineFeaturesType = {
        cellEdit: GridCellEdit
        cellMenu: CellMenu
        cellTooltip: CellTooltip
        columnAutoWidth: ColumnAutoWidth
        columnDragToolbar: ColumnDragToolbar
        columnLines: ColumnLines
        columnPicker: ColumnPicker
        columnReorder: ColumnReorder
        columnResize: ColumnResize
        contextMenu: ContextMenu
        dependencies: SchedulerDependencies
        dependencyEdit: SchedulerDependencyEdit
        eventContextMenu: EventContextMenu
        eventCopyPaste: EventCopyPaste
        eventDrag: EventDrag
        eventDragCreate: EventDragCreate
        eventDragSelect: EventDragSelect
        eventEdit: EventEdit
        eventFilter: EventFilter
        eventMenu: EventMenu
        eventResize: SchedulerEventResize
        eventTooltip: EventTooltip
        excelExporter: ExcelExporter
        filter: Filter
        filterBar: FilterBar
        group: Group
        groupSummary: GroupSummary
        headerContextMenu: HeaderContextMenu
        headerMenu: HeaderMenu
        headerZoom: HeaderZoom
        labels: SchedulerLabels
        nonWorkingTime: NonWorkingTime
        pan: Pan
        pdfExport: SchedulerPdfExport
        quickFind: QuickFind
        regionResize: RegionResize
        resourceTimeRanges: ResourceTimeRanges
        rowCopyPaste: RowCopyPaste
        rowReorder: RowReorder
        scheduleContext: ScheduleContext
        scheduleContextMenu: ScheduleContextMenu
        scheduleMenu: ScheduleMenu
        scheduleTooltip: ScheduleTooltip
        search: Search
        simpleEventEdit: SimpleEventEdit
        sort: Sort
        stickyCells: StickyCells
        stickyEvents: StickyEvents
        stripe: Stripe
        summary: Summary
        timeAxisHeaderMenu: TimeAxisHeaderMenu
        timeRanges: TimeRanges
        tree: Tree
    }

    type TimelineFeaturesConfigType = {
        cellEdit: string|boolean|Partial<GridCellEditConfig>
        cellMenu: string|boolean|Partial<CellMenuConfig>
        cellTooltip: string|boolean|Partial<CellTooltipConfig>
        columnAutoWidth: string|boolean|Partial<ColumnAutoWidthConfig>
        columnDragToolbar: string|boolean|Partial<ColumnDragToolbarConfig>
        columnLines: string|boolean|Partial<ColumnLinesConfig>
        columnPicker: string|boolean|Partial<ColumnPickerConfig>
        columnReorder: string|boolean|Partial<ColumnReorderConfig>
        columnResize: string|boolean|Partial<ColumnResizeConfig>
        contextMenu: string|boolean|Partial<ContextMenuConfig>
        dependencies: string|boolean|Partial<SchedulerDependenciesConfig>
        dependencyEdit: string|boolean|Partial<SchedulerDependencyEditConfig>
        eventContextMenu: string|boolean|Partial<EventContextMenuConfig>
        eventCopyPaste: string|boolean|Partial<EventCopyPasteConfig>
        eventDrag: string|boolean|Partial<EventDragConfig>
        eventDragCreate: string|boolean|Partial<EventDragCreateConfig>
        eventDragSelect: string|boolean|Partial<EventDragSelectConfig>
        eventEdit: string|boolean|Partial<EventEditConfig>
        eventFilter: string|boolean|Partial<EventFilterConfig>
        eventMenu: string|boolean|Partial<EventMenuConfig>
        eventResize: string|boolean|Partial<SchedulerEventResizeConfig>
        eventTooltip: string|boolean|Partial<EventTooltipConfig>
        excelExporter: string|boolean|Partial<ExcelExporterConfig>
        filter: string|boolean|Partial<FilterConfig>
        filterBar: string|boolean|Partial<FilterBarConfig>
        group: string|boolean|Partial<GroupConfig>
        groupSummary: string|boolean|Partial<GroupSummaryConfig>
        headerContextMenu: string|boolean|Partial<HeaderContextMenuConfig>
        headerMenu: string|boolean|Partial<HeaderMenuConfig>
        headerZoom: string|boolean|Partial<HeaderZoomConfig>
        labels: string|boolean|Partial<SchedulerLabelsConfig>
        nonWorkingTime: string|boolean|Partial<NonWorkingTimeConfig>
        pan: string|boolean|Partial<PanConfig>
        pdfExport: string|boolean|Partial<SchedulerPdfExportConfig>
        quickFind: string|boolean|Partial<QuickFindConfig>
        regionResize: string|boolean|Partial<RegionResizeConfig>
        resourceTimeRanges: string|boolean|Partial<ResourceTimeRangesConfig>
        rowCopyPaste: string|boolean|Partial<RowCopyPasteConfig>
        rowReorder: string|boolean|Partial<RowReorderConfig>
        scheduleContext: string|boolean|Partial<ScheduleContextConfig>
        scheduleContextMenu: string|boolean|Partial<ScheduleContextMenuConfig>
        scheduleMenu: string|boolean|Partial<ScheduleMenuConfig>
        scheduleTooltip: string|boolean|Partial<ScheduleTooltipConfig>
        search: string|boolean|Partial<SearchConfig>
        simpleEventEdit: string|boolean|Partial<SimpleEventEditConfig>
        sort: string|boolean|Partial<SortConfig>
        stickyCells: string|boolean|Partial<StickyCellsConfig>
        stickyEvents: string|boolean|Partial<StickyEventsConfig>
        stripe: string|boolean|Partial<StripeConfig>
        summary: string|boolean|Partial<SummaryConfig>
        timeAxisHeaderMenu: string|boolean|Partial<TimeAxisHeaderMenuConfig>
        timeRanges: string|boolean|Partial<TimeRangesConfig>
        tree: string|boolean|Partial<TreeConfig>
    }

    type TimelineConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        allowCreate: boolean
        allowDropOnEventBar: boolean
        allowOver: boolean
        allowOverlap: boolean
        anchor: boolean
        anchorToTarget: boolean
        animateRemovingRows: boolean
        appendTo: HTMLElement|string
        assignmentStore: SchedulerAssignmentStore|object|Partial<SchedulerAssignmentStoreConfig>
        assignments: SchedulerAssignmentModel[]|object[]|Partial<SchedulerAssignmentModelConfig>[]
        autoAdjustTimeAxis: boolean
        autoClose: boolean
        autoHeight: boolean
        autoShow: boolean
        barMargin: number
        bbar: object[]|object
        bodyCls: string|object
        bubbleEvents: object
        bufferCoef: number
        bufferThreshold: number
        centered: boolean
        closable: boolean
        closeAction: string
        cls: string|object
        columnLines: boolean
        columns: object[]|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        contextMenuTriggerEvent: string
        createEventOnDblClick: boolean|object
        creationTooltip: object
        crudManager: object|CrudManager|Partial<CrudManagerConfig>
        crudManagerClass: CrudManager
        data: object[]
        dataset: object
        defaultBindProperty: string
        defaultRegion: string
        defaultResourceImageName: string
        defaults: object
        dependencies: SchedulerDependencyModel[]|object[]|Partial<SchedulerDependencyModelConfig>[]
        dependencyStore: SchedulerDependencyStore|object|Partial<SchedulerDependencyStoreConfig>
        descriptionRenderer: Function
        destroyStore: boolean
        destroyStores: boolean
        disableGridRowModelWarning: boolean
        disabled: boolean
        dismissDelay: number
        displayDateFormat: string
        dock: string
        draggable: boolean|object
        durationDisplayPrecision: number|boolean
        emptyText: string
        enableDeleteKey: boolean
        enableEventAnimations: boolean
        enableRecurringEvents: boolean
        enableSticky: boolean
        enableTextSelection: boolean
        enableUndoRedoKeys: boolean
        endDate: Date|string
        endParamName: string
        eventBarTextField: string
        eventBodyTemplate: Function
        eventColor: string
        eventLayout: string
        eventRenderer: Function
        eventRendererThisObj: object
        eventSelectionDisabled: boolean
        eventStore: SchedulerEventStore|object|Partial<SchedulerEventStoreConfig>
        eventStyle: string
        events: SchedulerEventModel[]|object[]|Partial<SchedulerEventModelConfig>[]
        features: Partial<TimelineFeaturesConfigType>
        fillLastColumn: boolean
        fillTicks: boolean
        fixedRowHeight: boolean
        flex: number|string
        floating: boolean
        focusOnToFront: boolean
        footer: object|string
        forElement: HTMLElement
        forSelector: string
        forceFit: boolean
        fullRowRefresh: boolean
        getDateConstraints: Function
        getHtml: Function
        getRowHeight: Function
        header: string|PanelHeader
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideDelay: number
        hideHeaders: boolean
        hideOnDelegateChange: boolean
        hideWhenEmpty: boolean
        highlightPredecessors: boolean
        highlightSuccessors: boolean
        horizontalEventSorterFn: Function
        hoverDelay: number
        html: string
        htmlCls: string|object
        id: string
        infiniteScroll: boolean
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        loadMask: string|object|null
        loadMaskDefaults: object|Mask|Partial<MaskConfig>
        loadMaskError: object|Mask|Partial<MaskConfig>
        loadingMsg: string
        localeClass: Base
        localizableProperties: string[]
        longPressTime: number
        maintainSelectionOnDatasetChange: boolean
        managedEventSizing: boolean
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        maxZoomLevel: number
        maximizable: boolean
        maximized: boolean
        milestoneAlign: string
        milestoneCharWidth: number
        milestoneLayoutMode: string
        milestoneTextPosition: string
        minHeight: string|number
        minWidth: string|number
        minZoomLevel: number
        modal: boolean
        mode: string
        monitorResize: boolean
        mouseOffsetX: number
        mouseOffsetY: number
        multiEventSelect: boolean
        namedItems: object
        owner: Widget
        partner: TimelineBase
        passStartEndParameters: boolean
        plugins: Function[]
        positioned: boolean
        preCalculateHeightLimit: number
        preserveFocusOnDatasetChange: boolean
        preserveScrollOnDatasetChange: boolean
        presets: object[]
        preventTooltipOnTouch: boolean
        project: SchedulerProProjectModel|object|Partial<SchedulerProProjectModelConfig>
        readOnly: boolean
        ref: string
        removeUnassignedEvent: boolean
        resizeToFitIncludesHeader: boolean
        resourceColumns: object
        resourceImageExtension: string
        resourceImagePath: string
        resourceMargin: number
        resourceStore: SchedulerResourceStore|object|Partial<SchedulerResourceStoreConfig>
        resourceTimeRangeStore: ResourceTimeRangeStore|object|Partial<ResourceTimeRangeStoreConfig>
        resourceTimeRanges: ResourceTimeRangeModel[]|object[]|Partial<ResourceTimeRangeModelConfig>[]
        resources: SchedulerResourceModel[]|object[]|Partial<SchedulerResourceModelConfig>[]
        responsiveLevels: object
        ripple: boolean|object
        rootElement: ShadowRoot
        rowHeight: number
        scrollAction: string
        scrollManager: object|ScrollManager|Partial<ScrollManagerConfig>
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        scrollerClass: Scroller
        selectionMode: object
        showAnimation: boolean|object
        showCreationTooltip: boolean
        showDirty: boolean
        showOnClick: boolean
        showOnHover: boolean
        showRecurringUI: boolean
        showRemoveRowInContextMenu: boolean
        snap: boolean
        snapRelativeToEventStartDate: boolean
        startDate: Date|string
        startParamName: string
        stickyHeaders: boolean
        store: Store|object|Partial<StoreConfig>
        strips: object
        style: string
        subGridConfigs: object
        suppressFit: boolean
        syncMask: string|object|null
        tab: boolean|object
        tag: string
        tbar: object[]|object
        terminalCls: string
        terminalSides: string[]
        textAlign: string
        textContent: boolean
        tickSize: number
        timeAxis: object|TimeAxis|Partial<TimeAxisConfig>
        timeRangeStore: Store|object|Partial<StoreConfig>
        timeRanges: TimeSpan[]|object[]|Partial<TimeSpanConfig>[]
        title: string
        tools: object
        tooltip: string|object
        transitionDuration: number
        trapFocus: boolean
        triggerSelectionChangeOnRemove: boolean
        useInitialAnimation: boolean|string
        verticalTimeAxisColumn: object
        viewPreset: string|object
        visibleDate: Date|object
        visibleZoomFactor: number
        weekStartDay: number
        weight: number
        width: string|number
        workingTime: object
        x: number
        y: number
        zoomKeepsOriginalTimespan: boolean
        zoomOnMouseWheel: boolean
        zoomOnTimeAxisDoubleClick: boolean
    }

    export class Timeline extends Scheduler {
        features: TimelineFeaturesType
        constructor(config?: Partial<TimelineConfig>);
    }

    type AdvancedTabConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        textContent: boolean
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class AdvancedTab extends FormTab {
        constructor(config?: Partial<AdvancedTabConfig>);
    }

    type DependencyTabConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        dependencyIdField: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        taskComboSortField: string
        textAlign: string
        textContent: boolean
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export abstract class DependencyTab extends EditorTab {
        constructor(config?: Partial<DependencyTabConfig>);
    }

    type EditorTabConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        textContent: boolean
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class EditorTab extends Container implements EventLoader {
        constructor(config?: Partial<EditorTabConfig>);
    }

    type FormTabConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        textContent: boolean
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class FormTab extends EditorTab {
        constructor(config?: Partial<FormTabConfig>);
    }

    type GeneralTabConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        textContent: boolean
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class GeneralTab extends FormTab {
        constructor(config?: Partial<GeneralTabConfig>);
    }

    type NotesTabConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        textContent: boolean
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class NotesTab extends FormTab {
        constructor(config?: Partial<NotesTabConfig>);
    }

    type PredecessorsTabConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        dependencyIdField: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        taskComboSortField: string
        textAlign: string
        textContent: boolean
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class PredecessorsTab extends DependencyTab {
        constructor(config?: Partial<PredecessorsTabConfig>);
    }

    type ResourcesTabConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        textContent: boolean
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class ResourcesTab extends EditorTab {
        constructor(config?: Partial<ResourcesTabConfig>);
    }

    type SchedulerAdvancedTabConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        textContent: boolean
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class SchedulerAdvancedTab extends FormTab {
        constructor(config?: Partial<SchedulerAdvancedTabConfig>);
    }

    type SchedulerGeneralTabConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        textAlign: string
        textContent: boolean
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class SchedulerGeneralTab extends FormTab {
        constructor(config?: Partial<SchedulerGeneralTabConfig>);
    }

    type SuccessorsTabConfig = {
        adopt: HTMLElement|string
        align: object|string
        alignSelf: string
        anchor: boolean
        appendTo: HTMLElement|string
        bubbleEvents: object
        centered: boolean
        cls: string|object
        constrainTo: HTMLElement|Widget|Rectangle
        content: string
        contentElementCls: string|object
        dataset: object
        defaultBindProperty: string
        defaults: object
        dependencyIdField: string
        disabled: boolean
        dock: string
        draggable: boolean|object
        flex: number|string
        floating: boolean
        height: string|number
        hidden: boolean
        hideAnimation: boolean|object
        hideWhenEmpty: boolean
        html: string
        htmlCls: string|object
        id: string
        insertBefore: HTMLElement|string
        insertFirst: HTMLElement|string
        itemCls: string
        items: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        layout: string
        layoutStyle: object
        lazyItems: object|object[]|Widget[]|Partial<WidgetConfig>|Partial<WidgetConfig>[]
        listeners: object
        localeClass: Base
        localizableProperties: string[]
        margin: number|string
        maskDefaults: object|Mask|Partial<MaskConfig>
        masked: boolean|string|object|Mask|Partial<MaskConfig>
        maxHeight: string|number
        maxWidth: string|number
        minHeight: string|number
        minWidth: string|number
        monitorResize: boolean
        namedItems: object
        owner: Widget
        positioned: boolean
        preventTooltipOnTouch: boolean
        readOnly: boolean
        ref: string
        ripple: boolean|object
        rootElement: ShadowRoot
        scrollAction: string
        scrollable: boolean|object|Scroller|Partial<ScrollerConfig>
        showAnimation: boolean|object
        style: string
        tab: boolean|object
        tag: string
        taskComboSortField: string
        textAlign: string
        textContent: boolean
        title: string
        tooltip: string|object
        weight: number
        width: string|number
        x: number
        y: number
    }

    export class SuccessorsTab extends DependencyTab {
        constructor(config?: Partial<SuccessorsTabConfig>);
    }

    export class EventLoader {
    }

}
