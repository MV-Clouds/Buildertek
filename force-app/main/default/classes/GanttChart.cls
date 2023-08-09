/*
 Copyright (c) 2017-2018, BuilderTek.
 All rights reserved.

 Developed By: Sagar
 Date:  08-Jan-2018
 */
public with sharing class GanttChart{
	public string JSONString;
	public GanttChart(){
	}

	public GanttChart(List<Schedule__c> schedules, List<Project_Task__c> tasks, Project__c project){
		List<Data> Data = new List<Data>();
		List<Links> Links = new List<Links>();
		Map<String, Integer> Phases = new Map<String, Integer>();
		Integer i = 1;
		Integer j = 1;
		Data d;

		for (Schedule__c Schedule : schedules){
			// default schedule node
			d = new Data();
			d.id = Schedule.Id;
			d.text = Schedule.Name;
			d.contractorResource = '';

			//date todayDate = date.newInstance(1989, 4, 21);
			Date todayDate = date.newInstance(2019, 4, 21);

			if (Schedule.Start_Date__c != null){
				d.start_date = Schedule.Start_Date__c.day()+'-' + Schedule.Start_Date__c.month()+'-' + Schedule.Start_Date__c.year();
				//tempDate=Schedule.Start_Date__c;
			} else{
				d.start_date = todayDate.day()+'-' + todayDate.month()+'-' + todayDate.year();
				//tempDate=todayDate;
			}
			if (Schedule.Total_Duration__c != null)
				d.duration = string.valueOf(Schedule.Total_Duration__c);
			else
				d.duration = string.valueOf(1);
			d.resource = '';
			d.progress = '0';
			d.internalResource = '';
			d.contractor = '';
			d.progress1 = '';
			d.open = true;
			d.type = 'project';
			d.color = 'rgb(177,156,217)';
			d.stage = 1;
			Data.add(d);

		}
        Project_Task__c LastTask;
		for (Project_Task__c task : tasks){
            system.debug(task);
			if (task.Duration__c == null || task.Duration__c == 0)
				task.Duration__c = 1;
			if (!String.isBlank(task.Phase__c) && !Phases.containsKey(task.Phase__c)){
				Phases.put(task.Phase__c, j);
				d = new Data();
				d.id = task.Phase__c;
				d.text = task.Phase__c;
				d.contractorResource = '-';
				// if (task.buildertek__Contractor_Resource__r.Name != null){
				//     d.contractorResource = task.buildertek__Contractor_Resource__r.Name;
				// }
				d.contractorResource = '';
				if (d.start_date != null){
					d.start_date = task.Start__c.day()+'-' + task.Start__c.month()+'-' + task.Start__c.year();
				}
				d.duration = string.valueOf(task.Duration__c);
				d.progress = '0';
				d.progress1 = '';
				d.open = true;
				d.type = 'project';
				d.parent = task.schedule__c;
				// if (task.Resource__c != null)
				//     d.resource = task.Resource__r.Name;
				// else
				d.resource = '';
				if (String.isNotBlank(task.buildertek__Dependency__c)){
					d.dependency = task.buildertek__Dependency__c;
				} else{
					d.dependency = '';
				}

				if (task.buildertek__Lag__c != null){
					d.lag = task.buildertek__Lag__c;
				}
				// if (task.buildertek__Notes__c != null)
				//     d.notes = task.buildertek__Notes__c;
				// else
				d.notes = '';
				// if (task.buildertek__Contractor__c != null && task.buildertek__Contractor__r.Name != null){
				//     d.contractor = task.buildertek__Contractor__r.Name;
				// }else{
				d.contractor = '';
				// }
				// if (task.buildertek__Resource__c != null && task.buildertek__Resource__r.Name != null){
				//     d.internalResource = task.buildertek__Resource__r.Name;
				// }else{
				d.internalResource = '';
				d.stage = 2;
				// }
				Data.add(d);
				j++;
			}
			if (!task.buildertek__Milestone__c){
				//Project Tasks if not Milestone
				LastTask = task;
                /*system.debug(LastTask);
                system.debug(LastTask.buildertek__Start__c);
                system.debug(LastTask.Finish__c);*/
                d = new Data();
				d.id = task.Id;
				d.text = task.Name;
				d.contractorResource = '-';
				if (task.buildertek__Contractor_Resource__r.Name != null){
					d.contractorResource = task.buildertek__Contractor_Resource__r.Name;
				}
				if (task.Start__c != null){
					d.start_date = task.Start__c.day()+'-' + task.Start__c.month()+'-' + task.Start__c.year();
				}
				if (task.Finish__c != null){
					Date eDate = task.Finish__c;
					eDate = eDate.addDays(1);
					d.end_date = eDate.day()+'-' + eDate.month()+'-' + eDate.year();
				}
				if (task.Duration__c != null){
					d.duration = string.valueOf(task.Duration__c);
				} else{
					d.duration = string.valueOf(1);
				}
				task.Completion__c = task.Completion__c==null ? 0 : task.Completion__c;
				d.progress = string.valueOf(task.Completion__c != null ? task.Completion__c / 100 : 0);
				d.progress1 = string.valueOf((task.Completion__c != null ? task.Completion__c : 0).round())+'%';
				d.open = true;
				d.type = 'task';

				if (task.Completion__c == 100){
					d.color = 'rgb(93, 219, 70)';// Task is completed Green color
				} else if (task.Finish__c != null && task.Finish__c < System.today() && task.Completion__c < 100){
					d.color = 'rgb(224, 25, 25)';
				}else{
					d.color = 'rgb(61,185,211)';
				}
				if (task.Resource__c != null)
					d.resource = task.Resource__r.Name;
				else
					d.resource = '-';
				if (!String.isBlank(task.Phase__c))
					d.parent = task.Phase__c;
				else
					d.parent = task.schedule__c;
				if (String.isNotBlank(task.buildertek__Dependency__c)){
					d.dependency = task.buildertek__Dependency__c;
				} else{
					d.dependency = '';
				}
				if (task.buildertek__Lag__c != null){
					d.lag = task.buildertek__Lag__c;
				}
				if (task.buildertek__Notes__c != null)
					d.notes = task.buildertek__Notes__c;
				else
					d.notes = '';
				if (task.buildertek__Contractor__c != null && task.buildertek__Contractor__r.Name != null){
					d.contractor = task.buildertek__Contractor__r.Name;
				} else{
					d.contractor = '-';
				}
				if (task.buildertek__Resource__c != null && task.buildertek__Resource__r.Name != null){
					d.internalResource = task.buildertek__Resource__r.Name;
				} else{
					d.internalResource = '-';
				}
				d.stage = 3;
				Data.add(d);
			} else{
				//Milestone
				system.debug('LastTask ---->  '+LastTask);
               
				d = new Data();
				d.id = task.Id;
				d.text = 'Milestone Complete';
				d.contractorResource = '-';
				if (task.buildertek__Contractor_Resource__r.Name != null){
					d.contractorResource = task.buildertek__Contractor_Resource__r.Name;
				}
				if (task.Start__c != null){
					d.start_date = task.Start__c.day()+'-' + task.Start__c.month()+'-' + task.Start__c.year();
				}
                system.debug(task.Finish__c);
                if(LastTask != null){
                    if(LastTask.Finish__c != null){
                        Date eDate = LastTask.Finish__c;
                        eDate = eDate.addDays(1);
                        d.end_date = eDate.day()+'-' + eDate.month()+'-' + eDate.year();
                    }
                }else{
                    if (task.Finish__c != null){
                        Date eDate = task.Finish__c;
                        eDate = eDate.addDays(1);
                        d.end_date = eDate.day()+'-' + eDate.month()+'-' + eDate.year();
                        system.debug(d.end_date+'finish '+task.Finish__c+'start--'+d.start_date);
                    }
                }
				/*if (task.Finish__c != null){
					Date eDate = task.Finish__c;
					eDate = eDate.addDays(1);
					d.end_date = eDate.day()+'-' + eDate.month()+'-' + eDate.year();
                    system.debug(d.end_date+'finish '+task.Finish__c+'start--'+d.start_date);
				}*/
				if (task.Duration__c != null && Integer.valueOf(task.Duration__c) > 0){
					d.duration = string.valueOf(task.Duration__c);
				} else{
					d.duration = string.valueOf(1);
				}
				d.progress = '0';
				d.progress1 = '0' + '%';
				d.open = true;
				d.type = 'milestone';
				if (task.Resource__c != null)
					d.resource = task.Resource__r.Name;
				else
					d.resource = '-';
				if (!String.isBlank(task.Phase__c))
					d.parent = task.Phase__c;
				else
					d.parent = task.schedule__c;
				if (String.isNotBlank(task.buildertek__Dependency__c)){
					d.dependency = task.buildertek__Dependency__c;
				} else{
					d.dependency = '';
				}
                if (task.buildertek__Lag__c != null){
					d.lag = task.buildertek__Lag__c;
				}
				if (task.buildertek__Notes__c != null)
					d.notes = task.buildertek__Notes__c;
				else
					d.notes = '';
				if (task.buildertek__Contractor__c != null && task.buildertek__Contractor__r.Name != null){
					d.contractor = task.buildertek__Contractor__r.Name;
				} else{
					d.contractor = '-';
				}
				if (task.buildertek__Resource__c != null && task.buildertek__Resource__r.Name != null){
					d.internalResource = task.buildertek__Resource__r.Name;
				} else{
					d.internalResource = '-';
				}
				d.stage = 4;
                system.debug('d.type'+d.type+'d.end_date'+d.end_date);
				Data.add(d);
			}


			if (task.Dependency__c != null){
				Links link = new Links();
				link.id = string.valueOf(i);
				link.source = task.Dependency__c;
				link.target = task.id;
				link.type = '0'; //type – (string) the type of the dependency: “0” – ‘finish to start’, “1” – ‘start to start’, “2” – ‘finish to finish’, “3” – ‘start to finish’.
				link.lag = task.Lag__c != null ? Integer.valueOf(task.Lag__c) : 0;
				Links.add(link);
				i++;
			}
		}
		ganttChartData ganttdata = new ganttChartData();
		ganttdata.links = Links;
		ganttdata.Data = Data;
        //system.debug(Data[0].end_date);
        for(Data dup : Data){
            system.debug(dup);
        }
		JSONString = JSON.serialize(ganttdata);
	}

	public GanttChart(List<Project_Task__c> tasks, Project__c project){
		List<Data> Data = new List<Data>();
		List<Links> Links = new List<Links>();
		Map<String, Integer> Phases = new Map<String, Integer>();
		Integer i = 1;
		Integer j = 1;

		// default project node
		Data d = new Data();
		d.id = project.Id;
		d.text = project.Name;
		d.progress = '0';
		d.progress1 = '';
		d.open = true;
		d.type = 'project';
		d.stage = 1;
		Data.add(d);

		for (Project_Task__c task : tasks){
			if (!String.isBlank(task.Phase__c) && !Phases.containsKey(task.Phase__c)){
				Phases.put(task.Phase__c, j);
				d = new Data();
				d.id = task.Phase__c;
				d.text = task.Phase__c;
				d.start_date = task.Start__c.day()+'-' + task.Start__c.month()+'-' + task.Start__c.year();
				d.duration = string.valueOf(task.Duration__c);
				d.progress = '0';
				d.progress1 = '';
				d.open = true;
				d.type = 'project';
				d.parent = project.Id;
				if (task.Resource__c != null)
					d.resource = task.Resource__r.Name;
				else
					d.resource = '-';
				if (String.isNotBlank(task.buildertek__Dependency__c)){
					d.dependency = task.buildertek__Dependency__c;
				} else{
					d.dependency = '';
				}
				if (task.buildertek__Lag__c != null){
					d.lag = task.buildertek__Lag__c;
				}
				if (task.buildertek__Notes__c != null)
					d.notes = task.buildertek__Notes__c;
				else
					d.notes = '';
				if (task.buildertek__Contractor__c != null && task.buildertek__Contractor__r.Name != null){
					d.contractor = task.buildertek__Contractor__r.Name;
				} else{
					d.contractor = '-';
				}

				if (task.buildertek__Resource__c != null && task.buildertek__Resource__r.Name != null){
					d.internalresource = task.buildertek__Resource__r.Name;
				} else{
					d.internalResource = '-';
				}
				d.stage = 2;
				Data.add(d);
				j++;
			}

			if (!task.buildertek__Milestone__c){
				d = new Data();
				d.id = task.Id;
				d.text = task.Name;
				d.start_date = task.Expected_End_Date__c.day()+'-' + task.Expected_End_Date__c.month()+'-' + task.Expected_End_Date__c.year();
				d.duration = string.valueOf(task.Duration__c);
				d.progress = string.valueOf(task.Completion__c != null ? task.Completion__c / 100 : 0);
				d.progress1 = string.valueOf((task.Completion__c != null ? task.Completion__c / 100 : 0).round())+'%';
				d.open = true;
				d.type = 'task';
				if (task.Resource__c != null)
					d.resource = task.Resource__r.Name;
				else
					d.resource = '-';
				if (!String.isBlank(task.Phase__c))
					d.parent = task.Phase__c;
				else
					d.parent = task.schedule__c;
				if (String.isNotBlank(task.buildertek__Dependency__c)){
					d.dependency = task.buildertek__Dependency__c;
				} else{
					d.dependency = '';
				}

				if (task.buildertek__Lag__c != null){
					d.lag = task.buildertek__Lag__c;
				}
				if (task.buildertek__Notes__c != null)
					d.notes = task.buildertek__Notes__c;
				else
					d.notes = '';
				if (task.buildertek__Contractor__c != null && task.buildertek__Contractor__r.Name != null){
					d.contractor = task.buildertek__Contractor__r.Name;
				} else{
					d.contractor = '-';
				}
				task.Completion__c = task.Completion__c==null ? 0 : task.Completion__c;
				if (task.Completion__c == 100){
					d.color = 'rgb(93, 219, 70)';// Task is completed Green color
				} else if (task.Finish__c != null && task.Finish__c < System.today() && task.Completion__c < 100){
					d.color = 'rgb(224, 25, 25)';
				}else{
					d.color = 'rgb(61,185,211)';
				}
				if (task.buildertek__Resource__c != null && task.buildertek__Resource__r.Name != null){
					d.internalResource = task.buildertek__Resource__r.Name;
				} else{
					d.internalResource = '-';
				}
				if (task.Finish__c != null){
					Date eDate = task.Finish__c;
					eDate = eDate.addDays(1);
					d.end_date = eDate.day()+'-' + eDate.month()+'-' + eDate.year();
				}
				d.stage = 2;
				Data.add(d);
			} else{
				d = new Data();
				d.id = task.Id;
				d.text = task.Name;
				d.start_date = task.Start__c.day()+'-' + task.Start__c.month()+'-' + task.Start__c.year();
				d.duration = '1';
				d.open = true;
				d.type = 'milestone';
				if (!String.isBlank(task.Phase__c))
					d.parent = task.Phase__c;
				else
					d.parent = task.schedule__c;
				if (task.Finish__c != null){
					Date eDate = task.Finish__c;
                    system.debug(eDate+' '+task.Finish__c);
					eDate = eDate.addDays(1);
					d.end_date = eDate.day()+'-' + eDate.month()+'-' + eDate.year();
				}
				d.stage = 3;
				Data.add(d);
                system.debug(Data);
			}

			if (task.Dependency__c != null){
				Links link = new Links();
				link.id = string.valueOf(i);
				link.source = task.Dependency__c;
				link.target = task.id;
				link.type = '0'; //type – (string) the type of the dependency: “0” – ‘finish to start’, “1” – ‘start to start’, “2” – ‘finish to finish’, “3” – ‘start to finish’.
				link.lag = task.Lag__c != null ? Integer.valueOf(task.Lag__c) : 0;
				Links.add(link);
				i++;
			}
		}

		ganttChartData ganttdata = new ganttChartData();
		ganttdata.links = Links;
		ganttdata.Data = Data;

		JSONString = JSON.serialize(ganttdata);
	}

	public String getJSON(){
		return JSONString;
	}

	public class ganttChartData{
		public List<Data> data{ get; set; }

		public List<Links> links{ get; set; }
	}

	public class Links{
		public String id{ get; set; }

		public String source{ get; set; }

		public String target{ get; set; }

		public String type{ get; set; }

		public integer lag{ get; set; }
	}

	public class Data{
		public String id{ get; set; }

		public String text{ get; set; }

		public String start_date{ get; set; }

		public String end_date{ get; set; }

		public String duration{ get; set; }

		public String progress{ get; set; }

		public string progress1{ get; set; }

		public string dependency{ get; set; }

		public string internalResource{ get; set; }

		public string contractor{ get; set; }

		public string contractorResource{ get; set; }

		public Boolean open{ get; set; }

		public String type{ get; set; }

		public String parent{ get; set; }

		public String resource{ get; set; }

		public String color{ get; set; }

		public Decimal lag{ get; set; }

		public String notes{ get; set; }

		public Integer order{ get; set; }

		public Integer stage{ get; set; }

		public String templates{ get; set; }

		public String scheduleId{ get; set; }
	}
}