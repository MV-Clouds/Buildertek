const taskDate = function(dt){
    var droppedDate = convert(dt);
    droppedDate = addDays(droppedDate, 1);
    var timezoneValue = getTimeZone(droppedDate);
    var datetime = new Date(droppedDate);
    var offsetValue = timezoneValue.split(':');
    if(offsetValue[0].includes('-')){
        offsetValue[0] = offsetValue[0].replace('-', '');
        datetime.setHours(datetime.getHours()+parseInt(offsetValue[0]));  
        datetime.setMinutes(datetime.getHours()+offsetValue[1]);
    }else{
        datetime.setHours(datetime.getHours()-parseInt(offsetValue[0]));    
    }
    //component.set("v.finishDate", droppedDate);
    var currentDay = getDayOfWeek(datetime);
    console.log('currentDay -------> '+currentDay);
    if(currentDay != 'Sunday' && currentDay != 'Saturday'){
        var startDate;
        if(currentDay == 'Saturday'){
            startDate = addDays(datetime, 0);    
        }else if(currentDay == 'Sunday'){
            startDate = addDays(datetime, 1);        
        } 
        
    } 
    return startDate;
    
       
}
function getTimeZone(newDate) {
    var offset = newDate.getTimezoneOffset(), o = Math.abs(offset);
    return (offset < 0 ? "+" : "-") + ("00" + Math.floor(o / 60)).slice(-2) + ":" + ("00" + (o % 60)).slice(-2);
}

function getDayOfWeek(date) {
  const dayOfWeek = new Date(date).getDay();    
  return isNaN(dayOfWeek) ? null : 
    ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][dayOfWeek];
}
function addDays(date, days) {
  var result = new Date(date);
  result.setDate(result.getDate() + days);
  return result;
}

function convert(str) {
  var date = new Date(str),
    mnth = ("0" + (date.getMonth() + 1)).slice(-2),
    day = ("0" + date.getDate()).slice(-2);
  return [date.getFullYear(), mnth, day].join("-");
}

export{taskDate};