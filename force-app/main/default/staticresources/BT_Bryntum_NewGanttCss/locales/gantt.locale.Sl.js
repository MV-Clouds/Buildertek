/*!
 *
 * Bryntum Gantt 5.3.6
 *
 * Copyright(c) 2023 Bryntum AB
 * https://bryntum.com/contact
 * https://bryntum.com/license
 *
 */
(function(s,i){var l=typeof exports=="object";if(typeof define=="function"&&define.amd)define([],i);else if(typeof module=="object"&&module.exports)module.exports=i();else{var p=i(),m=l?exports:s;for(var c in p)m[c]=p[c]}})(typeof self<"u"?self:void 0,()=>{var s={},i={exports:s},l=Object.defineProperty,p=Object.getOwnPropertyDescriptor,m=Object.getOwnPropertyNames,c=Object.prototype.hasOwnProperty,u=(e,a,o)=>a in e?l(e,a,{enumerable:!0,configurable:!0,writable:!0,value:o}):e[a]=o,j=(e,a)=>{for(var o in a)l(e,o,{get:a[o],enumerable:!0})},k=(e,a,o,n)=>{if(a&&typeof a=="object"||typeof a=="function")for(let t of m(a))!c.call(e,t)&&t!==o&&l(e,t,{get:()=>a[t],enumerable:!(n=p(a,t))||n.enumerable});return e},g=e=>k(l({},"__esModule",{value:!0}),e),b=(e,a,o)=>(u(e,typeof a!="symbol"?a+"":a,o),o),v={};j(v,{default:()=>f}),i.exports=g(v);var d=class{static mergeLocales(...e){let a={};return e.forEach(o=>{Object.keys(o).forEach(n=>{typeof o[n]=="object"?a[n]={...a[n],...o[n]}:a[n]=o[n]})}),a}static trimLocale(e,a){let o=(n,t)=>{e[n]&&(t?e[n][t]&&delete e[n][t]:delete e[n])};Object.keys(a).forEach(n=>{Object.keys(a[n]).length>0?Object.keys(a[n]).forEach(t=>o(n,t)):o(n)})}static normalizeLocale(e,a){if(!e)throw new Error('"nameOrConfig" parameter can not be empty');if(typeof e=="string"){if(!a)throw new Error('"config" parameter can not be empty');a.locale?a.name=e||a.name:a.localeName=e}else a=e;let o={};if(a.name||a.locale)o=Object.assign({localeName:a.name},a.locale),a.desc&&(o.localeDesc=a.desc),a.code&&(o.localeCode=a.code),a.path&&(o.localePath=a.path);else{if(!a.localeName)throw new Error(`"config" parameter doesn't have "localeName" property`);o=Object.assign({},a)}for(let n of["name","desc","code","path"])o[n]&&delete o[n];if(!o.localeName)throw new Error("Locale name can not be empty");return o}static get locales(){return globalThis.bryntum.locales||{}}static set locales(e){globalThis.bryntum.locales=e}static get localeName(){return globalThis.bryntum.locale||"En"}static set localeName(e){globalThis.bryntum.locale=e||d.localeName}static get locale(){return d.localeName&&this.locales[d.localeName]||this.locales.En||Object.values(this.locales)[0]||{localeName:"",localeDesc:"",localeCoode:""}}static publishLocale(e,a){let{locales:o}=globalThis.bryntum,n=d.normalizeLocale(e,a),{localeName:t}=n;return!o[t]||a===!0?o[t]=n:o[t]=this.mergeLocales(o[t]||{},n||{}),o[t]}},r=d;b(r,"skipLocaleIntegrityCheck",!1),globalThis.bryntum=globalThis.bryntum||{},globalThis.bryntum.locales=globalThis.bryntum.locales||{},r._$name="LocaleHelper";var D={localeName:"Sl",localeDesc:"Slovensko",localeCode:"sl",RemoveDependencyCycleEffectResolution:{descriptionTpl:"Odstrani odvisnost"},DeactivateDependencyCycleEffectResolution:{descriptionTpl:"Deaktiviraj odvisnost"},CycleEffectDescription:{descriptionTpl:"Najden je bil cikel, ki ga tvori: {0}"},EmptyCalendarEffectDescription:{descriptionTpl:'"{0}" koledar ne predvideva delovnih časovnih intervalov.'},Use24hrsEmptyCalendarEffectResolution:{descriptionTpl:"Uporabi 24-urni koledar z dela prostimi sobotami in nedeljami."},Use8hrsEmptyCalendarEffectResolution:{descriptionTpl:"Uporabi 8-urni koledar (08:00-12:00, 13:00-17:00) z dela prostimi sobotami in nedeljami."},ConflictEffectDescription:{descriptionTpl:"Najden je bil konflikt pri razporedu {0} je v konfliktu z {1}"},ConstraintIntervalDescription:{dateFormat:"LLL"},ProjectConstraintIntervalDescription:{startDateDescriptionTpl:"Datum začetka projekta {0}",endDateDescriptionTpl:"Datum konca projekta {0}"},DependencyType:{long:["Od začetka do začetka","Od začetka do konca","Od konca do začetka","Od konca do konca"]},ManuallyScheduledParentConstraintIntervalDescription:{startDescriptionTpl:'Ročno načrtovan "{2}" prisili podrejene zahtevke da se ne začnejo prej kot {0}',endDescriptionTpl:'Ročno načrtovan "{2}" prisili podrejene zahtevke da se ne začnejo prej kot {1}'},DisableManuallyScheduledConflictResolution:{descriptionTpl:'Onemogoči ročno razporejanje za "{0}"'},DependencyConstraintIntervalDescription:{descriptionTpl:'Odvisnost ({2}) od "{3}" do "{4}"'},RemoveDependencyResolution:{descriptionTpl:'Odstrani odvisnost od "{1}" do "{2}"'},DeactivateDependencyResolution:{descriptionTpl:'Deaktiviraj odvisnost od "{1}" do "{2}"'},DateConstraintIntervalDescription:{startDateDescriptionTpl:'Naloga "{2}" {3} {0} omejitev',endDateDescriptionTpl:'Naloga "{2}" {3} {1} omejitev',constraintTypeTpl:{startnoearlierthan:"Začetek ne prej kot",finishnoearlierthan:"Končati ne prej kot",muststarton:"Začeti se mora na",mustfinishon:"Končati se mora na",startnolaterthan:"Začetek najkasneje",finishnolaterthan:"Končati najkasneje"}},RemoveDateConstraintConflictResolution:{descriptionTpl:'Odstrani "{1}" omejitev naloge "{0}"'}},N=r.publishLocale(D),h={localeName:"Sl",localeDesc:"Slovensko",localeCode:"sl",Object:{Yes:"Da",No:"Ne",Cancel:"Prekliči",Ok:"OK",Week:"Teden"},Combo:{noResults:"Ni rezultatov",recordNotCommitted:"Zapisa ni bilo mogoče dodati",addNewValue:e=>` Dodajte ${e}`},FilePicker:{file:"Datoteka"},Field:{badInput:"Neveljavna vrednost polja",patternMismatch:"Vrednost se mora ujemati z določenim vzorcem",rangeOverflow:e=>` Vrednost mora biti manjša ali enaka ${e.max}`,rangeUnderflow:e=>` Vrednost mora biti večja ali enaka ${e.min}`,stepMismatch:"Vrednost mora ustrezati koraku",tooLong:"Vrednost naj bo krajša",tooShort:"Vrednost naj bo daljša",typeMismatch:"Vrednost mora biti v posebni obliki",valueMissing:"To polje je obvezno",invalidValue:"Neveljavna vrednost polja",minimumValueViolation:"Kršitev najmanjše vrednosti",maximumValueViolation:"Kršitev največje vrednosti",fieldRequired:"To polje je obvezno",validateFilter:"Vrednost mora biti izbrana s seznama"},DateField:{invalidDate:"Neveljaven vnos datuma"},DatePicker:{gotoPrevYear:"Pojdi na prejšnje leto",gotoPrevMonth:"Pojdi na prejšnji mesec",gotoNextMonth:"Pojdi na naslednji mesec",gotoNextYear:"Pojdi na naslednje leto"},NumberFormat:{locale:"sl",currency:"EUR"},DurationField:{invalidUnit:"Neveljavna enota"},TimeField:{invalidTime:"Neveljaven vnos časa"},TimePicker:{hour:"Ura",minute:"Minuta",second:"Drugi"},List:{loading:"Nalaganje..."},GridBase:{loadMask:"Nalaganje...",syncMask:"Shranjevanje sprememb, prosim počakajte ..."},PagingToolbar:{firstPage:"Pojdi na prvo stran",prevPage:"Pojdi na prejšnjo stran",page:"Stran",nextPage:"Pojdi na naslednjo stran",lastPage:"Pojdi na zadnjo stran",reload:"Znova naloži trenutno stran",noRecords:"Ni zapisov za prikaz",pageCountTemplate:e=>`od ${e.lastPage}`,summaryTemplate:e=>` Prikaz zapisov ${e.start} - ${e.end} od ${e.allCount}`},PanelCollapser:{Collapse:"Strni",Expand:"Razširi"},Popup:{close:"Zapri pojavno okno"},UndoRedo:{Undo:"Razveljavi",Redo:"Ponovno uveljav",UndoLastAction:"Razveljavi zadnje dejanje",RedoLastAction:"Ponovi zadnje razveljavljeno dejanje",NoActions:"V čakalni vrsti za razveljavitev ni elementov"},FieldFilterPicker:{equals:"enako",doesNotEqual:"ni enako",isEmpty:"je prazno",isNotEmpty:"ni prazno",contains:"vsebuje",doesNotContain:"ne vsebuje",startsWith:"začne se z",endsWith:"konča se z",isOneOf:"je eden od",isNotOneOf:"ni eden od",isGreaterThan:"je večje kot",isLessThan:"je manjše kot",isGreaterThanOrEqualTo:"je večje ali enako",isLessThanOrEqualTo:"je manjše ali enako",isBetween:"je vmes",isNotBetween:"ni vmes",isBefore:"je pred",isAfter:"je potem",isToday:"je danes",isTomorrow:"je jutri",isYesterday:"je včeraj",isThisWeek:"je ta teden",isNextWeek:"je naslednji teden",isLastWeek:"je prejšnji teden",isThisMonth:"je ta mesec",isNextMonth:"je naslednji mesec",isLastMonth:"je prejšnji mesec",isThisYear:"je to leto",isNextYear:"je naslednje leto",isLastYear:"je prejšnje leto",isYearToDate:"je leto do danes",isTrue:"je res",isFalse:"je napačno",selectAProperty:"Izberite lastnost",selectAnOperator:"Izberite operaterja",caseSensitive:"Razlikuje med velikimi in malimi črkami",and:"in",dateFormat:"D/M/YY",selectOneOrMoreValues:"Izberite eno ali več vrednosti",enterAValue:"Vnesite vrednost",enterANumber:"Vnesite številko",selectADate:"Izberite datum"},FieldFilterPickerGroup:{addFilter:"Dodajte filter"},DateHelper:{locale:"sl",weekStartDay:1,nonWorkingDays:{0:!0,6:!0},weekends:{0:!0,6:!0},unitNames:[{single:"milisekunda",plural:"milisekunde",abbrev:"ms"},{single:"sekunda",plural:"sekunde",abbrev:"s"},{single:"minuta",plural:"minute",abbrev:"min"},{single:"ura",plural:"ure",abbrev:"ur"},{single:"dan",plural:"dnevi",abbrev:"d"},{single:"teden",plural:"tedni",abbrev:"t"},{single:"mesec",plural:"meseci",abbrev:"m"},{single:"četrtletje",plural:"četrtletja",abbrev:"četrt"},{single:"leto",plural:"leta",abbrev:"l"},{single:"desetletje",plural:"desetletja",abbrev:"des"}],unitAbbreviations:[["ms"],["s","sek"],["m","min"],["ur","ur"],["d"],["t","t"],["m","m","m"],["četrt","četrt","četrt"],["l","l"],["des"]],parsers:{L:"D. M. YYYY.",LT:"HH:mm ",LTS:"HH:mm:ss A"},ordinalSuffix:e=>e+"."}},E=r.publishLocale(h),y=new String,z={localeName:"Sl",localeDesc:"Slovensko",localeCode:"sl",ColumnPicker:{column:"Stolpec",columnsMenu:"Stolpci",hideColumn:"Skrij stolpec",hideColumnShort:"Skrij",newColumns:"Novi stolpci"},Filter:{applyFilter:"Uporabi filter",filter:"Filter",editFilter:"Uredi filter",on:"Vklopljeno",before:"Prej",after:"Po",equals:"Enako",lessThan:"Manj kot",moreThan:"Več kot",removeFilter:"Odstrani filter",disableFilter:"Onemogoči filter"},FilterBar:{enableFilterBar:"Pokaži vrstico s filtri",disableFilterBar:"Skrij vrstico s filtri"},Group:{group:"Skupina",groupAscending:"Skupina narašča",groupDescending:"Skupina pada",groupAscendingShort:"Naraščajoče",groupDescendingShort:"Padajoče",stopGrouping:"Ustavi združevanje",stopGroupingShort:"Ustavi"},HeaderMenu:{moveBefore:e=>` Premakni pred"${e}"`,moveAfter:e=>` Premakni za "${e}"`,collapseColumn:"Strni stolpec",expandColumn:"Razširi stolpec"},ColumnRename:{rename:"Preimenuj"},MergeCells:{mergeCells:"Združi celice",menuTooltip:"Združi celice z isto vrednostjo, ko so razvrščene po tem stolpcu"},Search:{searchForValue:"Išči vrednost"},Sort:{sort:"Razvrsti",sortAscending:"Razvrsti naraščajoče",sortDescending:"Razvrsti padajoče",multiSort:"Več razvrstitev",removeSorter:"Odstrani razvrščevalnik",addSortAscending:"Dodaj naraščajoči razvrščevalnik",addSortDescending:"Dodaj padajoči razvrščevalnik",toggleSortAscending:"Spremeni v naraščajoče",toggleSortDescending:"Spremeni v padajoče",sortAscendingShort:"Naraščajoče",sortDescendingShort:"Padajoče",removeSorterShort:"Odstrani",addSortAscendingShort:"+Naraščajoče",addSortDescendingShort:"+Padajoče"},Column:{columnLabel:e=>`${e.text?`${e.text} stolpec. `:""}PRESLEDNICA za kontekstni meni${e.sortable?", VNESI za razvrstitev":""}`,cellLabel:y},Checkbox:{toggleRowSelect:"Preklop izbire vrstice",toggleSelection:"Preklopi izbor celotnega nabora podatkov"},RatingColumn:{cellLabel:e=>{var a;return`${e.text?e.text:""} ${(a=e.location)!=null&&a.record?`ocena : ${e.location.record[e.field]||0}`:""}`}},GridBase:{loadFailedMessage:"Nalaganje podatkov ni uspelo!",syncFailedMessage:"Sinhronizacija podatkov ni uspela!",unspecifiedFailure:"Nedoločena napaka",networkFailure:"Napaka omrežja",parseFailure:"Razčlenitev odgovora strežnika ni uspela",serverResponse:"Odziv strežnika:",noRows:"Ni zapisov za prikaz",moveColumnLeft:"Premakni se v levi odsek",moveColumnRight:"Premakni se v desni odsek",moveColumnTo:e=>` Premakni stolpec v ${e}`},CellMenu:{removeRow:"Izbriši"},RowCopyPaste:{copyRecord:"Kopiraj",cutRecord:"Izreži",pasteRecord:"Prilepi",rows:"vrstice",row:"vrstica"},CellCopyPaste:{copy:"Kopiraj",cut:"Izreži",paste:"Prilepi"},PdfExport:{"Waiting for response from server":"Čakanje na odgovor strežnika ...","Export failed":"Izvoz ni uspel","Server error":"Napaka strežnika","Generating pages":"Ustvarjanje strani ...","Click to abort":"Prekliči"},ExportDialog:{width:"40em",labelWidth:"12em",exportSettings:"Izvozi nastavitve",export:"Izvozi",exporterType:"Nadzor številčenja strani",cancel:"Prekliči",fileFormat:"Oblika datoteke",rows:"Vrstice",alignRows:"Poravnaj vrstice",columns:"Stolpci",paperFormat:"Format papirja",orientation:"Orientacija",repeatHeader:"Ponovi glavo"},ExportRowsCombo:{all:"Vse vrstice",visible:"Vidne vrstice"},ExportOrientationCombo:{portrait:"Portret",landscape:"Pokrajina"},SinglePageExporter:{singlepage:"Ena stran"},MultiPageExporter:{multipage:"Več strani",exportingPage:({currentPage:e,totalPages:a})=>`Izvažanje strani ${e}/${a}`},MultiPageVerticalExporter:{multipagevertical:"Več strani (navpično)",exportingPage:({currentPage:e,totalPages:a})=>`Izvažanje strani ${e}/${a}`},RowExpander:{loading:"Nalaganje",expand:"Razširi",collapse:"Strni"}},R=r.publishLocale(z),S={localeName:"Sl",localeDesc:"Slovensko",localeCode:"sl",Object:{newEvent:"Nov dogodek"},ResourceInfoColumn:{eventCountText:e=>e+" dogod"+(e!==1?"ke":"ek")},Dependencies:{from:"Od",to:"Do",valid:"Veljavno",invalid:"Neveljavno"},DependencyType:{SS:"ZZ",SF:"ZK",FS:"KZ",FF:"KK",StartToStart:"Od začetka do začetka",StartToEnd:"Od začetka do konca",EndToStart:"Od konca do začetka",EndToEnd:"Od konca do konca",short:["SS","SF","FS","FF"],long:["Od začetka do začetka","Od začetka do konca","Od konca do začetka","Od konca do konca"]},DependencyEdit:{From:"Od",To:"Do",Type:"Vrsta",Lag:"Zaostajanje","Edit dependency":"Uredi odvisnost",Save:"Shrani",Delete:"Izbriši",Cancel:"Prekliči",StartToStart:"Od začetka do začetka",StartToEnd:"Od začetka do konca",EndToStart:"Od konca do začetka",EndToEnd:"Od konca do konca"},EventEdit:{Name:"Ime",Resource:"Vir",Start:"Začetek",End:"Konec",Save:"Shrani",Delete:"Izbriši",Cancel:"Prekliči","Edit event":"Uredi dogodek",Repeat:"Ponovi"},EventDrag:{eventOverlapsExisting:"Dogodek prekriva obstoječi dogodek za ta vir",noDropOutsideTimeline:"Dogodek ne sme biti popolnoma izpuščen izven časovnice"},SchedulerBase:{"Add event":"Dodaj dogodek","Delete event":"Izbriši dogodek","Unassign event":"Prekliči dodelitev dogodka"},TimeAxisHeaderMenu:{pickZoomLevel:"Povečaj",activeDateRange:"Datumski obseg",startText:"Začetni datum",endText:"Končni datum",todayText:"Danes"},EventCopyPaste:{copyEvent:"Kopiraj dogodek",cutEvent:"Izreži dogodek",pasteEvent:"Prilepi dogodek"},EventFilter:{filterEvents:"Filtriraj opravila",byName:"Po imenu"},TimeRanges:{showCurrentTimeLine:"Pokaži trenutno časovnico"},PresetManager:{secondAndMinute:{displayDateFormat:"ll LTS",name:"Sekunde"},minuteAndHour:{topDateFormat:"ddd MM/DD, hA",displayDateFormat:"ll LST"},hourAndDay:{topDateFormat:"ddd MM/DD",middleDateFormat:"LST",displayDateFormat:"ll LST",name:"Dan"},day:{name:"Dan/ure"},week:{name:"Teden/ure"},dayAndWeek:{displayDateFormat:"ll LST",name:"Teden/dnevi"},dayAndMonth:{name:"Mesec"},weekAndDay:{displayDateFormat:"ll LST",name:"Teden"},weekAndMonth:{name:"Tedni"},weekAndDayLetter:{name:"Tedni/delavniki"},weekDateAndMonth:{name:"Meseci/tedni"},monthAndYear:{name:"Meseci"},year:{name:"Leta"},manyYears:{name:"Več let"}},RecurrenceConfirmationPopup:{"delete-title":"Brišete dogodek","delete-all-message":"Želite izbrisati vse pojavitve tega dogodka?","delete-further-message":"Želite izbrisati to in vse prihodnje pojavitve tega dogodka ali samo trenutno pojavitev?","delete-further-btn-text":"Izbriši vse prihodnje dogodke","delete-only-this-btn-text":"Izbriši samo ta dogodek","update-title":"Spreminjate ponavljajoči se dogodek","update-all-message":"Želite spremeniti vse pojavitve tega dogodka?","update-further-message":"Želite spremeniti samo to pojavitev dogodka ali to in vse prihodnje pojavitve?","update-further-btn-text":"Vsi prihodnji dogodki","update-only-this-btn-text":"Samo ta dogodek",Yes:"Da",Cancel:"Prekliči",width:600},RecurrenceLegend:{" and ":" in ",Daily:"Dnevno","Weekly on {1}":({days:e})=>` Tedensko ob ${e}`,"Monthly on {1}":({days:e})=>`Mesečno ob ${e}`,"Yearly on {1} of {2}":({days:e,months:a})=>`Letno ob ${e} v mesecu  ${a}`,"Every {0} days":({interval:e})=>`Vsakih ${e} dni`,"Every {0} weeks on {1}":({interval:e,days:a})=>` Vsakih ${e} tednov ob ${a}`,"Every {0} months on {1}":({interval:e,days:a})=>` Vsakih ${e} mesecev ob ${a}`,"Every {0} years on {1} of {2}":({interval:e,days:a,months:o})=>` Vsakih ${e} let ob ${a} v mesecu ${o}`,position1:"prvi",position2:"drugi",position3:"tretji",position4:"četrti",position5:"peti","position-1":"zadnji",day:"dan",weekday:"delovni dan","weekend day":"dan za vikend",daysFormat:({position:e,days:a})=>`${e} ${a}`},RecurrenceEditor:{"Repeat event":"Ponovi dogodek",Cancel:"Prekliči",Save:"Shrani",Frequency:"Pogostost",Every:"Vsak",DAILYintervalUnit:"dan",WEEKLYintervalUnit:"teden",MONTHLYintervalUnit:"mesec",YEARLYintervalUnit:"leto",Each:"Vsak","On the":"Na","End repeat":"Končaj ponavljanje","time(s)":"krat"},RecurrenceDaysCombo:{day:"dan",weekday:"delovni dan","weekend day":"dan za vikend"},RecurrencePositionsCombo:{position1:"prvi",position2:"drugi",position3:"tretji",position4:"četrti",position5:"peti","position-1":"zadnji"},RecurrenceStopConditionCombo:{Never:"Nikoli",After:"Po","On date":"Na datum"},RecurrenceFrequencyCombo:{None:"Brez ponavljanja",Daily:"Dnevno",Weekly:"Tedensko",Monthly:"Mesečno",Yearly:"Letno"},RecurrenceCombo:{None:"Brez",Custom:"Po meri..."},Summary:{"Summary for":e=>` Povzetek za ${e}`},ScheduleRangeCombo:{completeview:"Celoten urnik",currentview:"Viden urnik",daterange:"Datumski obseg",completedata:"Celoten urnik (za vse dogodke)"},SchedulerExportDialog:{"Schedule range":"Obseg urnika","Export from":"Od","Export to":"Do"},ExcelExporter:{"No resource assigned":"Ni dodeljenega vira"},CrudManagerView:{serverResponseLabel:"Odziv strežnika:"},DurationColumn:{Duration:"Trajanje"}},O=r.publishLocale(S),T={localeName:"Sl",localeDesc:"Slovensko",localeCode:"sl",ConstraintTypePicker:{none:"Brez",muststarton:"Začeti se mora na",mustfinishon:"Končati se mora na",startnoearlierthan:"Začetek ne prej kot",startnolaterthan:"Začetek najkasneje",finishnoearlierthan:"Končati ne prej kot",finishnolaterthan:"Končati najkasneje"},CalendarField:{"Default calendar":"Privzeti koledar"},TaskEditorBase:{Information:"Informacija",Save:"Shrani",Cancel:"Prekliči",Delete:"Izbriši",calculateMask:"Računanje...",saveError:"Ni mogoče shraniti, najprej popravite napake",repeatingInfo:"Ogled ponavljajočega se dogodka",editRepeating:"Uredi"},TaskEdit:{"Edit task":"Uredi opravilo",ConfirmDeletionTitle:"Potrdi brisanje",ConfirmDeletionMessage:"Ste prepričani, da želite izbrisati dogodek?"},GanttTaskEditor:{editorWidth:"44em"},SchedulerTaskEditor:{editorWidth:"32em"},SchedulerGeneralTab:{labelWidth:"6em",General:"Splošno",Name:"Ime",Resources:"Viri","% complete":"% dokončano",Duration:"Trajanje",Start:"Začetek",Finish:"Konec",Effort:"Trud",Preamble:"Preambula",Postamble:"Poambula"},GeneralTab:{labelWidth:"6.5em",General:"Splošno",Name:"Ime","% complete":"% dokončano",Duration:"Trajanje",Start:"Začetek",Finish:"Konec",Effort:"Trud",Dates:"Datumi"},SchedulerAdvancedTab:{labelWidth:"13em",Advanced:"Napredno",Calendar:"Koledar","Scheduling mode":"Način razporejanja","Effort driven":"Gnano po naporu","Manually scheduled":"Ročno razporejeno","Constraint type":"Vrsta omejitve","Constraint date":"Datum omejitve",Inactive:"Neaktivno","Ignore resource calendar":"Prezri koledar virov"},AdvancedTab:{labelWidth:"11.5em",Advanced:"Napredno",Calendar:"Koledar","Scheduling mode":"Način razporejanja","Effort driven":"Gnano po naporu","Manually scheduled":"Ročno razporejeno","Constraint type":"Vrsta omejitve","Constraint date":"Datum omejitve",Constraint:"Omejitev",Rollup:"Poročilo v povzetek",Inactive:"Neaktivno","Ignore resource calendar":"Prezri koledar virov"},DependencyTab:{Predecessors:"Predhodniki",Successors:"Nasledniki",ID:"ID",Name:"Ime",Type:"Vrsta",Lag:"Zakasnitev",cyclicDependency:"Ciklična odvisnost",invalidDependency:"Neveljavna odvisnost"},NotesTab:{Notes:"Opombe"},ResourcesTab:{unitsTpl:({value:e})=>`${e}%`,Resources:"Viri",Resource:"Vir",Units:"Enote"},RecurrenceTab:{title:"Ponovi"},SchedulingModePicker:{Normal:"Normalno","Fixed Duration":"Stalno trajanje","Fixed Units":"Stalne enote","Fixed Effort":"Stalni napor"},ResourceHistogram:{barTipInRange:'<b>{resource}</b> {startDate} - {endDate}<br><span class="{cls}">{allocated} od {available}</span> dodeljenih',barTipOnDate:'<b>{resource}</b> on {startDate}<br><span class="{cls}">{allocated} od {available}</span> dodeljenih',groupBarTipAssignment:'<b>{resource}</b> - <span class="{cls}">{allocated} od {available}</span>',groupBarTipInRange:'{startDate} - {endDate}<br><span class="{cls}">{allocated} od {available}</span> allocated:<br>{assignments}',groupBarTipOnDate:'Na {startDate}<br><span class="{cls}">{allocated} od {available}</span> dodeljenih:<br>{assignments}',plusMore:"+{value} več"},ResourceUtilization:{barTipInRange:'<b>{event}</b> {startDate} - {endDate}<br><span class="{cls}">{allocated}</span> dodeljen',barTipOnDate:'<b>{event}</b> na {startDate}<br><span class="{cls}">{allocated}</span> dodeljen',groupBarTipAssignment:'<b>{event}</b> - <span class="{cls}">{allocated}</span>',groupBarTipInRange:'{startDate} - {endDate}<br><span class="{cls}">{allocated} od {available}</span> dodeljenih:<br>{assignments}',groupBarTipOnDate:'Na {startDate}<br><span class="{cls}">{allocated} od {available}</span> dodeljenih:<br>{assignments}',plusMore:"+{value} več",nameColumnText:"Vir / Dogodek"},SchedulingIssueResolutionPopup:{"Cancel changes":"Prekliči spremembo in ne stori ničesar",schedulingConflict:"Spor pri razporedu",emptyCalendar:"Napaka konfiguracije koledarja",cycle:"Cikel razporejanja",Apply:"Uporabi"},CycleResolutionPopup:{dependencyLabel:"Prosimo, izberite odvisnost:",invalidDependencyLabel:"Vključene so neveljavne odvisnosti, ki jih je treba obravnavati:"},DependencyEdit:{Active:"Aktivno"},SchedulerProBase:{propagating:"Preračunavanje projekta",storePopulation:"Nalaganje podatkov",finalizing:"Dokončevanje rezultatov"},EventSegments:{splitEvent:"Razdeli dogodek",renameSegment:"Preimenuj"},NestedEvents:{deNestingNotAllowed:"Odstranjevanje gnezdenja ni dovoljeno",nestingNotAllowed:"Gnezdenje ni dovoljeno"},VersionGrid:{compare:"Primerjaj",description:"Opis",occurredAt:"Zgodilo se ob",rename:"Preimenuj",restore:"Obnovi",stopComparing:"Prenehaj primerjati"},Versions:{entityNames:{TaskModel:"naloga",AssignmentModel:"dodelitev",DependencyModel:"povezava",ProjectModel:"projekt",ResourceModel:"vir",other:"predmet"},entityNamesPlural:{TaskModel:"naloge",AssignmentModel:"dodelitve",DependencyModel:"povezave",ProjectModel:"projekti",ResourceModel:"viri",other:"predmeti"},transactionDescriptions:{update:"Spremenjenih {n} {entities}",add:"Dodanih {n} {entities}",remove:"Odstranjenih {n} {entities}",move:"Premakjenih {n} {entities}",mixed:"Spremenjenih {n} {entities}"},addEntity:"Dodano {type} **{name}**",removeEntity:"Odstranjeno {type} **{name}**",updateEntity:"Spremenjeno {type} **{name}**",moveEntity:"Premaknjeno {type} **{name}** od {from} do {to}",addDependency:"Dodana povezava od **{from}** do **{to}**",removeDependency:"Odstranjena povezava od **{from}** do **{to}**",updateDependency:"Urejena povezava od **{from}** do **{to}**",addAssignment:"Dodeljen **{resource}** do **{event}**",removeAssignment:"Odstranjena dodelitev **{resource}** od **{event}**",updateAssignment:"Urejena dodelitev **{resource}** do **{event}**",noChanges:"Brez sprememb",nullValue:"nič",versionDateFormat:"M/D/YYYY h:mm a",undid:"Razveljavljene spremembe",redid:"Ponovno uvedene spremembe",editedTask:"Urejene lastnosti naloge",deletedTask:"Izbrisal nalogo",movedTask:"Premaknil nalogo",movedTasks:"Premaknjene naloge"}},M=r.publishLocale(T),P={localeName:"Sl",localeDesc:"Slovensko",localeCode:"sl",Object:{Save:"Shrani"},IgnoreResourceCalendarColumn:{"Ignore resource calendar":"Ignoriraj koledar virov"},InactiveColumn:{Inactive:"Neaktiven"},AddNewColumn:{"New Column":"Nov stolpec"},CalendarColumn:{Calendar:"Koledar"},EarlyStartDateColumn:{"Early Start":"Zgodnji začetek"},EarlyEndDateColumn:{"Early End":"Zgodnji konec"},LateStartDateColumn:{"Late Start":"Pozni začetek"},LateEndDateColumn:{"Late End":"Pozni konec"},TotalSlackColumn:{"Total Slack":"Kompletno mrtvilo"},ConstraintDateColumn:{"Constraint Date":"Datum omejitve"},ConstraintTypeColumn:{"Constraint Type":"Vrsta omejitve"},DeadlineDateColumn:{Deadline:"Rok"},DependencyColumn:{"Invalid dependency":"Neveljavna odvisnost"},DurationColumn:{Duration:"Trajanje"},EffortColumn:{Effort:"Trud"},EndDateColumn:{Finish:"Končaj"},EventModeColumn:{"Event mode":"Način dogodka",Manual:"Ročni",Auto:"Samodejni"},ManuallyScheduledColumn:{"Manually scheduled":"Ročno razporejeno"},MilestoneColumn:{Milestone:"Mejnik"},NameColumn:{Name:"Ime"},NoteColumn:{Note:"Opomba"},PercentDoneColumn:{"% Done":"% dokončano"},PredecessorColumn:{Predecessors:"Predhodniki"},ResourceAssignmentColumn:{"Assigned Resources":"Dodeljeni viri","more resources":"več virov"},RollupColumn:{Rollup:"Akumulacija"},SchedulingModeColumn:{"Scheduling Mode":"Način razporejanja"},SequenceColumn:{Sequence:"Zaporedje"},ShowInTimelineColumn:{"Show in timeline":"Pokaži na časovnici"},StartDateColumn:{Start:"Začetek"},SuccessorColumn:{Successors:"Nasledniki"},TaskCopyPaste:{copyTask:"Kopiraj",cutTask:"Izreži",pasteTask:"Prilepi"},WBSColumn:{WBS:"WBS",renumber:"Preštevilči"},DependencyField:{invalidDependencyFormat:"Neveljavna oblika odvisnosti"},ProjectLines:{"Project Start":"Začetek projekta","Project End":"Konec projekta"},TaskTooltip:{Start:"Začetek",End:"Konec",Duration:"Trajanje",Complete:"Dokončano"},AssignmentGrid:{Name:"Ime vira",Units:"Enote",unitsTpl:({value:e})=>e?e+"%":""},Gantt:{Edit:"Uredi",Indent:"Zamik",Outdent:"Odmik","Convert to milestone":"Pretvori v mejnik",Add:"Dodaj ...","New task":"Novo opravilo","New milestone":"Nov mejnik","Task above":"Opravilo zgoraj","Task below":"Opravilo spodaj","Delete task":"Izbriši",Milestone:"Mejnik","Sub-task":"Podopravilo",Successor:"Naslednik",Predecessor:"Predhodnik",changeRejected:"Mehanizem za razporejanje je zavrnil spremembe",linkTasks:"Dodaj odvisnosti",unlinkTasks:"Odstrani odvisnosti"},EventSegments:{splitTask:"Razdeli nalogo"},Indicators:{earlyDates:"Zgodnji začetek/konec",lateDates:"Pozni začetek/konec",Start:"Začetek",End:"Konec",deadlineDate:"Rok"},Versions:{indented:"Zamaknjeno",outdented:"Primaknjeno",cut:"Rezi",pasted:"Prilepljeno",deletedTasks:"Izbrisana opravila"}},f=r.publishLocale(P);if(typeof i.exports=="object"&&typeof s=="object"){var C=(e,a,o,n)=>{if(a&&typeof a=="object"||typeof a=="function")for(let t of Object.getOwnPropertyNames(a))!Object.prototype.hasOwnProperty.call(e,t)&&t!==o&&Object.defineProperty(e,t,{get:()=>a[t],enumerable:!(n=Object.getOwnPropertyDescriptor(a,t))||n.enumerable});return e};i.exports=C(i.exports,s)}return i.exports});
