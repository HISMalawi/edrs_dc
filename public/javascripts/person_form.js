function setAjaxUrl(case_number){

				switch(case_number) {
					    case 0:
					      	var district = __$('touchscreenInput' + tstCurrentPage).value;

					      	__$("person_hospital_of_death_name").setAttribute("ajaxURL","/facilities?district="+district)

					      	__$("person_place_of_death_ta").setAttribute("ajaxURL","/tas?district="+district)

					        break;
					    case 1:

					    	var ta = __$('touchscreenInput' + tstCurrentPage).value;

					    	var district = __$('person_place_of_death_district').value

					    	__$("person_place_of_death_village").setAttribute("ajaxURL","/villages?district="+district+"&ta="+ta)

					        break;
					    case 2:

					    	var district = __$('touchscreenInput' + tstCurrentPage).value;

					      	__$("person_home_ta").setAttribute("ajaxURL","/tas?district="+district)

					    	break;

					    case 3:

					    	var ta = __$('touchscreenInput' + tstCurrentPage).value;

					    	var district = __$('person_home_district').value

					    	__$("person_home_village").setAttribute("ajaxURL","/villages?district="+district+"&ta="+ta)

					        break;
					    case 4:

					    	var district = __$('touchscreenInput' + tstCurrentPage).value;

					      	__$("person_informant_current_ta").setAttribute("ajaxURL","/tas?district="+district)

					    	break;

					    case 5:

					    	var ta = __$('touchscreenInput' + tstCurrentPage).value;

					    	var district = __$('person_informant_current_district').value

					    	__$("person_informant_current_village").setAttribute("ajaxURL","/villages?district="+district+"&ta="+ta)

					        break;
				} 

		}

		function monthDaysKeyPad() {

		    var keyboard = __$("keyboard");

		    __$("inputFrame" + tstCurrentPage).style.height = "50px";

		    keyboard.innerHTML = "";

		    var keyPadDiv = document.createElement("div");

		    keyPadDiv.style.width = "40%";

		    keyPadDiv.style.float = "left";

		    keyboard.appendChild(keyPadDiv);

		    var months = {
		        "January": 0,
		        "February": 1,
		        "March": 2,
		        "April": 3,
		        "May": 4,
		        "June": 5,
		        "Juy": 6,
		        "August": 7,
		        "September": 8,
		        "October": 9,
		        "November": 10,
		        "December": 11
		    }

		    var year = __$("person_birth_year").value;

		    var month = __$("person_birth_month").value;

		    var nextMonthNumber = parseInt(months[month]) + 2;

		    var date = new Date(year + "-" + padZeros(nextMonthNumber, 2) + "-" + "01");

		    date.setDate(date.getDate() - 1);

		    var lateDayOfSelectedMonth = date.getDate()

		    var table = document.createElement("table");

		    table.style.width = "100%";

		    keyPadDiv.appendChild(table);


		    var tr;

		    for (var i = 1; i <= 31; i++) {

		        if ((i - 1) % 7 == 0) {

		            tr = document.createElement("tr");

		            table.appendChild(tr);

		        }

		        var td = document.createElement("td");

		        tr.appendChild(td);

		        var button = document.createElement("button");



		        td.appendChild(button);


		        if (i <= 9) {

		            button.innerHTML = "<span>" + i+"</span>";

		            button.setAttribute("onclick", '__$("touchscreenInput"+tstCurrentPage).value ="0"+' + i);

		        } else {

		            button.innerHTML = "<span>"+i+"</span>";

		            button.setAttribute("onclick", '__$("touchscreenInput"+tstCurrentPage).value =' + i);

		        }

		        if (i > parseInt(lateDayOfSelectedMonth)) {

		            button.className = "gray";

		            button.removeAttribute("onclick");
		        }
		        else {

		        }

		    }

		    var unknownButton = document.createElement("button");

		    unknownButton.innerHTML = "Unknown";

		    unknownButton.style.float = "right";

		    unknownButton.style.marginTop = "10%";

		    unknownButton.setAttribute("onclick", '__$("touchscreenInput"+tstCurrentPage).value ="Unknown"');

		    //keyboard.appendChild(unknownButton);

		}

		function setAgeValues() {

		    var birthyear = __$("person_birth_year").value;

		    var birthmonth = __$('person_birth_month').value;

		    var birthday = __$("person_birth_day").value;

		    if (birthday.trim().toLowerCase() == "unknown") {

		        birthday = "05";

		        __$("person_birthdate_estimated").value = 1;

		    } else {

		        __$("person_birthdate_estimated").value = 0;

		    }

		    var months = {
		        "January": 0,
		        "February": 1,
		        "March": 2,
		        "April": 3,
		        "May": 4,
		        "June": 5,
		        "Juy": 6,
		        "August": 7,
		        "September": 8,
		        "October": 9,
		        "November": 10,
		        "December": 11
		    }

		    var birthdate = birthyear + "-" + padZeros(parseInt(months[birthmonth]) + 1, 2) + "-" + padZeros(parseInt(birthday), 2);

		    __$("person_birthdate").value = birthdate;


		}

		function setEstimatedAgeValue() {

		    __$("person_birth_year").setAttribute("disabled", true);

		    __$("person_birth_month").setAttribute("disabled", true);

		    __$("person_birth_day").setAttribute("disabled", true);

		    if (__$("person_birthdate") && __$("person_age_estimate") && __$("person_birthdate_estimated")) {

		        if (__$("person_age_estimate").value.trim().length > 0) {

		            __$("person_birthdate_estimated").value = 1;

		            var year = (new Date()).getFullYear() - parseInt(__$("person_age_estimate").value.trim());

		            __$("person_birthdate").value = year + "-07-15";

		            console.log( __$("person_birthdate").value);

		        } else {

		            __$("person_estimate").value = 0;

		        }

		    }

		}
