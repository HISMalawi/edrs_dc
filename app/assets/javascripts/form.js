	function loadMinPersonSummary(){
		
		if (__$("keyboard")) {
			__$("keyboard").style.display = "none";
		}

		__$("clearButton").style.display ="none";
		
		var tstControl = __$("tt_page_summary");
		if (tstControl) {
			 tstControl.innerHTML = "";
		
       var table = document.createElement("table");
		        table.style.width = "100%";
		        
		         
		        table.style.borderCollapse = "collapse";

		       tstControl.appendChild(table);

		        var tr = document.createElement("tr");

		        table.appendChild(tr);

		        var th = document.createElement("th");
		        th.style.fontSize = "1.2em";
		        th.style.textAlign = "center";
		        th.style.backgroundColor = "#f2f2f2";
		        th.style.padding = "20px";
		        th.style.borderBottom = "1px solid #ccc";
		        th.innerHTML = "PARTICULARS OF THE DECEASED";

		        tr.appendChild(th);

		        var tr = document.createElement("tr");

		        table.appendChild(tr);

		        var td = document.createElement("td");

		        tr.appendChild(td);

		        var div = document.createElement("div");
		        div.style.width = "100%";
		        div.style.height = "calc(100vh - 180px)";
		        div.style.overflow = "auto";

		        td.appendChild(div);

		        var tableContent = document.createElement("table");
		        tableContent.style.width = "98%";
		        tableContent.style.borderCollapse = "collapse";
		        tableContent.cellPadding = "10px";
		        tableContent.style.border = "1px solid #ccc"
		        tableContent.style.fontSize = "1em";
		        tableContent.style.margin = "auto";
               


		        div.appendChild(tableContent);

		        var tr = document.createElement("tr");
		        tr.style.backgroundColor = "#f2f2f2";
		        tr.colSpan ="12";
		        tableContent.appendChild(tr);
		       

		        var td = document.createElement("td")
		        td.innerHTML = "Surname";
		        td.style.fontWeight = "bold";
		        td.style.borderLeft = "1px solid #ccc";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.colSpan ="12";
		        td.innerHTML = __$('person_last_name') && __$('person_last_name').value ? __$("person_last_name").value : "";
		        tr.appendChild(td)

		        var tr = document.createElement("tr");
		        tr.colSpan ="12";
		        tableContent.appendChild(tr);
		       
		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.innerHTML = "First name";
		        td.style.fontWeight = "bold";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.colSpan ="12";
		        td.style.border = "none";
		        td.innerHTML =__$('person_first_name') && __$('person_first_name').value ? __$("person_first_name").value : "";
		        tr.appendChild(td)


		        var tr = document.createElement("tr");
		        tr.style.backgroundColor = "#f2f2f2";
		        tr.colSpan ="12";
		        tableContent.appendChild(tr);
		        
		        var td = document.createElement("td");
		        td.style.borderLeft = "1px solid #ccc";
		        td.style.fontWeight = "bold";
		        td.innerHTML = "ID No.";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		         td.colSpan ="12";
		        td.innerHTML = (__$('person_id_number') && __$('person_id_number').value ? __$("person_id_number").value : "");
		        tr.appendChild(td);

                
                var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        
		        var td = document.createElement("td");
		        td.style.fontWeight = "bold";
		        td.innerHTML = "Sex";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.innerHTML = (__$('person_gender') && __$('person_gender').value ? __$("person_gender").value : "");
		        td.colSpan ="2";
		        tr.appendChild(td);



                var tr = document.createElement("tr");
		        tr.style.backgroundColor = "#f2f2f2";
		        tr.colSpan ="12";
		        tableContent.appendChild(tr);
		       
		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.innerHTML = "Date of Birth";
		        td.style.fontWeight = "bold";
		        tr.appendChild(td);
		        		        
		        var birthdate  = new Date(__$("person_birthdate").value).format();
		        
		       	if(__$('person_birthdate_estimated').value == 1) {
		       		birthdate = "??/??/"+(new Date(__$("person_birthdate").value).format("YYYY-mm-dd").split("-")[0]);
		       	}

		        var td = document.createElement("td");
		        td.colSpan ="12";
		        td.innerHTML = birthdate;
		        tr.appendChild(td);


		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.fontWeight = "bold";
		        td.innerHTML = "Date of death";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.colSpan ="5";
		        td.innerHTML = (__$("person_date_of_death") && __$("person_date_of_death").value ? (new Date(__$('person_date_of_death').value)).format() : "");
		        tr.appendChild(td);

		        var tr = document.createElement("tr");
		        tr.style.backgroundColor = "#f2f2f2";
		        tr.colSpan ="12";
		        tableContent.appendChild(tr);
		       

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.fontWeight = "bold";
		        td.innerHTML = "Place of Death";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		       	td.colSpan ="12";
		       	var place_of_death =(__$("person_place_of_death") && __$("person_place_of_death").value ? __$('person_place_of_death').value : "");
		       	
		       	if (place_of_death == 'Health Facility'){

		       		td.innerHTML = __$("person_hospital_of_death").value;

		        }else if(place_of_death == 'Home') {

		       		td.innerHTML = __$("person_place_of_death_district").value +" "+ __$("person_place_of_death_ta").value +" "+
						 				__$("person_place_of_death_village").value;

		        }else{

		       		 td.innerHTML = __$("person_other_place_of_death").value
		       	}
		        //td.innerHTML =(__$("person_place_of_death") && __$("person_place_of_death").value ? __$('person_place_of_death').value : "");
		        tr.appendChild(td);


		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);


                var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.fontWeight = "bold";
		        td.innerHTML = "Mother's name";
		        tr.appendChild(td);
		       
		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.innerHTML =( __$("person_mother_last_name") && __$("person_mother_last_name").value ? __$('person_mother_last_name').value : "") + " " + (__$("person_mother_first_name") && __$("person_mother_first_name").value ? __$('person_mother_first_name').value : "");
		        tr.appendChild(td);

		        var tr = document.createElement("tr");
		        tr.style.backgroundColor = "#f2f2f2";
		        tr.colSpan ="12";
		        tableContent.appendChild(tr);
		        
		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.fontWeight = "bold";
		        td.innerHTML = "Father's name";
		        tr.appendChild(td);
		       
		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.innerHTML = (__$("person_father_last_name") && __$("person_father_last_name").value ? __$('person_father_last_name').value : "") + " " + (__$("person_father_first_name") && __$("person_father_first_name").value ? __$('person_father_first_name').value : "");
		        tr.appendChild(td);

		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);

                var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.fontWeight = "bold";
		        td.innerHTML = "Informant's name";
		        tr.appendChild(td);
		       
		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.innerHTML =( __$("person_informant_last_name") && __$("person_informant_last_name").value ? __$('person_informant_last_name').value : "") + " " + (__$("person_informant_first_name") && __$("person_informant_first_name").value ? __$('person_informant_first_name').value : "");
		        tr.appendChild(td);


		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);

                var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.fontWeight = "bold";
		        td.innerHTML = "Informant relationship to deceased";
		        tr.appendChild(td);
		       
		        var td = document.createElement("td");
		        td.style.border = "none";
		        if(__$('person_informant_relationship_to_deceased').value.match('Other')){
		        	td.innerHTML =( __$("person_informant_relationship_to_deceased_other") && __$("person_informant_relationship_to_deceased_other").value ? __$('person_informant_relationship_to_deceased').value  + "  ," + __$('person_informant_relationship_to_deceased_other').value : "");
		        } else {
		        	td.innerHTML =( __$("person_informant_relationship_to_deceased") && __$("person_informant_relationship_to_deceased").value ? __$('person_informant_relationship_to_deceased').value : "");
		        }
		        
		        tr.appendChild(td);

		        
		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        
		        var td = document.createElement("td");
		        td.style.fontWeight = "bold";
		        td.innerHTML = "Date Reported";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.colSpan= "10"
		        td.style.borderBottom = "1px solid #ccc";
		        td.innerHTML =(__$("person_informant_signature_date") && __$("person_informant_signature_date").value ? (new Date( __$('person_informant_signature_date').value)).format() : "");
		        tr.appendChild(td);
		        
                





		}

	}
	function loadPersonSummary(){
		if (__$("keyboard")) {
			__$("keyboard").style.display = "none";
		}

		var tstControl = __$("tt_page_summary");
		if (tstControl) {
		    tstControl.innerHTML = "";
		    tstControl.style.backgroundColor ="#e6e6e6";

		        var table = document.createElement("table");
		        table.style.width = "100%";
		        table.style.borderCollapse = "collapse";

		       tstControl.appendChild(table);

		        var tr = document.createElement("tr");

		        table.appendChild(tr);

		        var th = document.createElement("th");
		        th.style.fontSize = "1.2em";
		        th.style.textAlign = "left";
		        th.style.padding = "20px";
		        th.style.borderBottom = "1px solid #ccc";
		        th.innerHTML = "SECTION 1: Particulars of the deceased";

		        tr.appendChild(th);

		        var tr = document.createElement("tr");

		        table.appendChild(tr);

		        var td = document.createElement("td");

		        tr.appendChild(td);

		        var div = document.createElement("div");
		        div.style.width = "100%";
		        div.style.height = "calc(100vh - 180px)";
		        div.style.overflow = "auto";

		        td.appendChild(div);

		        var tableContent = document.createElement("table");
		        tableContent.style.width = "98%";
		        tableContent.style.borderCollapse = "collapse";
		        tableContent.cellPadding = "3";
		        tableContent.style.border = "1px solid black"
		        tableContent.style.fontSize = "1em";
		        tableContent.style.margin = "auto";

		        div.appendChild(tableContent);


		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        var td = document.createElement("th")
		        td.innerHTML = "Part 1 <br/> PERSONAL DETAILS OF DECEASED";
		        td.rowSpan ="11";
		        td.style.width ="10%";
		        td.style.border = "1px solid black";
		        tr.appendChild(td)

		        var td = document.createElement("td");
		        td.style.textAlign = "right";
		        td.innerHTML = "1";
		        td.style.border = "1px solid black";
		        tr.appendChild(td);

		        var td = document.createElement("td")
		        td.innerHTML = "Surname";
		        td.style.fontWeight = "bold";
		        td.style.borderLeft = "1px solid black";
		        td.style.borderBottom = "1px solid black";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML = __$('person_last_name') && __$('person_last_name').value ? __$("person_last_name").value : "";
		        tr.appendChild(td)

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.innerHTML = "First name";
		        td.colSpan = "2";
		        td.style.borderBottom = "1px solid black";
		        td.style.fontWeight = "bold";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML =__$('person_first_name') && __$('person_first_name').value ? __$("person_first_name").value : "";
		        tr.appendChild(td)

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.fontWeight = "bold";
		        td.colSpan = "2";
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML = "Other names";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		   		td.style.borderBottom = "1px solid black";
		        td.innerHTML=(__$('person_middle_name') && __$('person_middle_name').value ? __$("person_middle_name").value : "");
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.borderLeft = "1px solid black";
		        td.innerHTML = "Barcode No";
		        td.style.borderBottom = "1px solid black";
		        td.style.fontWeight = "bold";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML = (__$('person_barcode') && __$('person_barcode').value ? __$("person_barcode").value : "");
		        tr.appendChild(td);

		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        var td = document.createElement("td");
		        td.style.border = "1px solid black";
		        td.innerHTML = "2";
		        td.style.textAlign = "right";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.borderLeft = "1px solid black";
		        td.style.borderBottom = "1px solid black";
		        td.style.fontWeight = "bold";
		        td.innerHTML = "ID No.";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.borderBottom = "1px solid black";
		        td.colSpan ="2";
		        td.innerHTML = (__$('person_id_number') && __$('person_id_number').value ? __$("person_id_number").value : "");
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "1px solid black";
		        td.innerHTML = "3";
		        td.style.textAlign = "right";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.borderBottom = "1px solid black";
		        td.style.fontWeight = "bold";
		        td.innerHTML = "Nationality";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML = (__$('person_nationality') && __$('person_nationality').value ? __$("person_nationality").value : "");
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "1px solid black";
		        td.innerHTML = "4";
		        td.style.textAlign = "right";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.borderBottom = "1px solid black";
		        td.style.fontWeight = "bold";
		        td.innerHTML = "Sex";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		         td.style.borderBottom = "1px solid black";
		        td.innerHTML = (__$('person_gender') && __$('person_gender').value ? __$("person_gender").value : "");
		        td.colSpan ="2";
		        tr.appendChild(td);

		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        var td = document.createElement("td");
		        td.style.border = "1px solid black";
		        td.innerHTML = "5";
		        td.style.textAlign = "right";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "1px solid black";
		        td.style.fontWeight = "bold";
		        td.innerHTML = "Date of Birth";
		        tr.appendChild(td);

		        var birthdate  = new Date(__$("person_birthdate").value).format();

		       	if(__$('person_birthdate_estimated').value == 1) {
		       		birthdate = "??/??/"+(new Date(__$("person_birthdate").value).format("YYYY-mm-dd").split("-")[0]);
		       	}

		        var td = document.createElement("td");
		         td.style.borderBottom = "1px solid black";
		        td.colSpan ="5";
		        td.innerHTML = birthdate;
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "1px solid black";
		        td.innerHTML = "6";
		        td.style.textAlign = "right";
		        td.rowSpan="2"
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.fontWeight = "bold";
		        td.innerHTML = "Birth Certificate No.";
		         td.style.borderBottom = "1px solid black";
		        td.rowSpan="2"
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.rowSpan="2"
		        td.style.border ="1px solid black";
		        td.colSpan ="2";
		        td.innerHTML = (__$('person_birth_certificate_number') && __$('person_birth_certificate_number').value ? __$("person_birth_certificate_number").value : "");
		        tr.appendChild(td);

		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        var td = document.createElement("td");
		        td.style.border = "1px solid black";
		        td.innerHTML = "7";
		        td.style.textAlign = "right";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.fontWeight = "bold";
		         td.style.borderBottom = "1px solid black";
		        td.innerHTML = "Date of death";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.borderBottom = "1px solid black";
		        td.colSpan ="5";
		        td.innerHTML = (__$("person_date_of_death") && __$("person_date_of_death").value ? (new Date(__$('person_date_of_death').value)).format() : "");
		        tr.appendChild(td);

		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        var td = document.createElement("td");
		        td.style.border = "1px solid black";
		        td.rowSpan ="4";
		        td.innerHTML = "8";
		        td.style.textAlign = "right";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.fontWeight = "bold";
		        td.innerHTML = "Place of Death";
		         td.style.borderBottom = "1px solid black";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		       	td.style.borderBottom = "1px solid black";
		        td.colSpan ="9";
		        td.innerHTML =(__$("person_place_of_death") && __$("person_place_of_death").value ? __$('person_place_of_death').value : "");
		        tr.appendChild(td);

		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.fontWeight = "bold";
		       td.innerHTML = "<input type='radio' name='place' id='facility'>Health Facility"
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.colSpan ="9";
		        td.style.borderBottom = "1px solid black";
		        
		        var hospital_of_death = "";

		        if(__$("person_hospital_of_death") && __$("person_hospital_of_death").value){
		        	hospital_of_death = __$('person_hospital_of_death').value;
		        }
		        if(__$("place_of_death_foreign_hospital") && __$("place_of_death_foreign_hospital").value){
		        	hospital_of_death =  __$('place_of_death_foreign_hospital').value ;
		        }
		        td.innerHTML = hospital_of_death;
		        
		        tr.appendChild(td);

		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.fontWeight = "bold";
		        td.innerHTML = "<input type='radio' name='place' id='home'>Home";
		        tr.appendChild(td);

		        //start
		        if(__$('person_place_of_death_country') && __$('person_place_of_death_country').value != "Malawi"){
		        	var td = document.createElement("td");
			        td.style.border = "none";
			        td.style.fontWeight = "bold";
			        td.style.borderBottom = "1px solid black";
			        td.colSpan ="2"
			        td.innerHTML = "Country :";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.border = "none";
			        td.style.textAlign ="left"
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML = __$('person_place_of_death_country').value
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.border = "none";
			        td.style.fontWeight = "bold";
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML = "Details:";
			        td.colSpan ="2";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.border = "none";
			        td.style.textAlign ="left"
			        td.colSpan ="2"
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML = (__$('person_place_of_death_foreign_hospital') && __$('person_place_of_death_foreign_hospital').value ? __$('person_place_of_death_foreign_hospital').value : "") +" "
			        			   +(__$('person_place_of_death_foreign_state') && __$('person_place_of_death_foreign_state').value ? __$('person_place_of_death_foreign_state').value : "")+" "
			        			   +(__$('person_place_of_death_foreign_district') && __$('person_place_of_death_foreign_district').value ? __$('person_place_of_death_foreign_district').value : "")+" "
			        			   +(__$('person_place_of_death_foreign_village') && __$('person_place_of_death_foreign_village').value ? __$('person_place_of_death_foreign_village').value : "")
			        tr.appendChild(td);
		        }else{
			        var td = document.createElement("td");
			        td.style.border = "none";
			        td.style.fontWeight = "bold";
			        td.style.borderBottom = "1px solid black";
			        td.colSpan ="2";
			        td.innerHTML = "District:";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.border = "none";
			        td.style.textAlign ="left"
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML =(__$("person_place_of_death").value=="Home" &&__$("person_place_of_death_district").value  ? __$('person_place_of_death_district').value : "");
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.border = "none";
			        td.style.fontWeight = "bold";
			        td.innerHTML = "TA:";
			        td.style.borderBottom = "1px solid black";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.border = "none";
			        td.style.textAlign ="left"
			        td.style.borderBottom = "1px solid black";
			        if(__$('person_place_of_death_ta')){
			        	if(__$("person_place_of_death_ta").value == "Other"){
			        		td.innerHTML =__$("person_other_place_of_death_ta").value;
			        	}else{
			        		td.innerHTML =__$("person_place_of_death_ta").value;
			        	}
			        }
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.border = "none";
			        td.style.fontWeight = "bold";
			        td.innerHTML = "Village:";
			        td.colSpan ="2";
			        td.style.borderBottom = "1px solid black";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.border = "none";
			        td.style.textAlign ="left"
			        td.style.borderBottom = "1px solid black";
			        td.colSpan ="2";
			         if(__$('person_place_of_death_village')){
			        	if(__$("person_place_of_death_village").value == "Other"){
			        		td.innerHTML =__$("person_other_place_of_death_village").value;
			        	}else{
			        		td.innerHTML =__$("person_place_of_death_village").value;
			        	}
			        }
			        tr.appendChild(td);
			    }
		        //end
		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        var td = document.createElement("td");
		        td.style.fontWeight = "bold";
		        td.innerHTML = "<input type='radio' name='place' id='other'>Other";
		        td.style.borderBottom = "1px solid black";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.borderBottom = "1px solid black";
		        td.colSpan ="9";
		        td.innerHTML =(__$("person_other_place_of_death") && __$("person_other_place_of_death").value ? __$('person_other_place_of_death').value : "");
		        tr.appendChild(td);

		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        var td = document.createElement("td");
		        td.style.border = "1px solid black";
		        td.innerHTML = "9";
		        td.style.textAlign = "right";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.fontWeight = "bold";
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML = "Physical address";
		        tr.appendChild(td);
				if(__$('person_current_country') && __$('person_current_country').value.trim().toLowerCase()=="malawi"){
			        var td = document.createElement("td");
			        td.style.border = "none";
			        td.innerHTML = "District :";
			        td.colSpan ="2";
			        td.style.borderBottom = "1px solid black";
			        td.style.fontWeight = "bold";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.border = "none";
			        td.style.textAlign ="left"
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML =(__$("person_current_district") && __$("person_current_district").value ? __$('person_current_district').value : "");
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.border = "none";
			        td.style.fontWeight = "bold";
			        td.innerHTML = "TA :";
			        td.style.borderBottom = "1px solid black";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.border = "none";
			        td.style.textAlign ="left"
			        td.style.borderBottom = "1px solid black";
			        if(__$('person_current_ta')){
			        	if(__$("person_current_ta").value == "Other"){
			        		td.innerHTML =__$("person_other_current_ta").value;
			        	}else{
			        		td.innerHTML =__$("person_current_ta").value;
			        	}
			        }
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.border = "none";
			        td.style.borderBottom = "1px solid black";
			        td.style.fontWeight = "bold";
			        td.innerHTML = "Village :";
			        td.colSpan ="2";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.border = "none";
			        td.colSpan ="2";
			        td.style.textAlign ="left"
			        td.style.borderBottom = "1px solid black";
			        if(__$('person_current_village')){
			        	if(__$("person_current_village").value == "Other"){
			        		td.innerHTML =__$("person_other_current_village").value;
			        	}else{
			        		td.innerHTML =__$("person_current_village").value;
			        	}
			        }
			        tr.appendChild(td);
			    }else{
			        var td = document.createElement("td");
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML = "Country: ";
			        td.style.fontWeight = "bold";
			        td.style.textAlign = "right";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML = (__$('person_current_country')? __$('person_current_country').value : "??");
			        td.style.textAlign = "left";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.innerHTML = "State: ";
			        td.style.textAlign = "right";
			        td.style.borderBottom = "1px solid black";
			        td.style.fontWeight = "bold";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML = (__$('person_current_foreign_state')? __$('person_current_foreign_state').value : "??");
			        td.style.textAlign = "left";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML = "District: ";
			        td.style.fontWeight = "bold";
			        td.style.textAlign = "right";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML = (__$('person_current_foreign_district')? __$('person_current_foreign_district').value : "??");
			        td.style.textAlign = "left";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.innerHTML = "Village: ";
			        td.style.borderBottom = "1px solid black";
			        td.style.fontWeight = "bold";
			        td.style.textAlign = "right";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.innerHTML = (__$('person_current_foreign_village')? __$('person_current_foreign_village').value : "??");
			        td.style.textAlign = "left";
			        td.style.borderBottom = "1px solid black";
			        td.colSpan ="2";
			        tr.appendChild(td);
			    }

		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        var td = document.createElement("td");
		        td.style.border = "1px solid black";
		        td.innerHTML = "10";
		        td.style.textAlign = "right";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.fontWeight = "bold";
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML = "Home address";
		        tr.appendChild(td);

				if(__$('person_home_country') &&__$('person_home_country').value.trim().toLowerCase()=='malawi'){
					var td = document.createElement("td");
			        td.style.border = "none";
			        td.style.fontWeight = "bold";
			        td.innerHTML = "District:";
			        td.colSpan ="2";
			        td.style.borderBottom = "1px solid black";
			        tr.appendChild(td);
	
			        var td = document.createElement("td");
			        td.style.border = "none";
			        td.style.textAlign ="left"
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML =__$("person_home_district") && __$("person_home_district").value ? __$('person_home_district').value : "";
			        tr.appendChild(td);
			        var td = document.createElement("td");
			        td.style.border = "none";
			        td.style.borderBottom = "1px solid black";
			        td.style.fontWeight = "bold";
			        td.innerHTML = "TA:";
			        tr.appendChild(td);
	
			        var td = document.createElement("td");
			        td.style.border = "none";
			        td.style.textAlign ="left"
			        td.style.borderBottom = "1px solid black";
			        if(__$('person_home_ta')){
			        	if(__$("person_home_ta").value == "Other"){
			        		td.innerHTML =__$("person_other_home_ta").value;
			        	}else{
			        		td.innerHTML =__$("person_home_ta").value;
			        	}
			        }
			        tr.appendChild(td);
	
			        var td = document.createElement("td");
			        td.style.border = "none";
			        td.style.borderBottom = "1px solid black";
			        td.style.fontWeight = "bold";
			        td.innerHTML = "Village:";
			        td.colSpan ="2";
			        tr.appendChild(td);
	
			        var td = document.createElement("td");
			        td.style.border = "none";
			        td.style.textAlign ="left"
			        td.style.borderBottom = "1px solid black";
			        td.colSpan ="2";
			        if(__$('person_home_village')){
			        	if(__$("person_home_village").value == "Other"){
			        		td.innerHTML =__$("person_other_home_village").value;
			        	}else{
			        		td.innerHTML =__$("person_home_village").value;
			        	}
			        }
			        tr.appendChild(td);
			    }else{

			        var td = document.createElement("td");
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML = "Country: ";
			        td.style.fontWeight = "bold";
			        td.style.textAlign = "right";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML = (__$('person_home_country')? __$('person_home_country').value : "??");
			        td.style.textAlign = "left";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.innerHTML = "State: ";
			        td.style.textAlign = "right";
			        td.style.borderBottom = "1px solid black";
			        td.style.fontWeight = "bold";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML = (__$('person_home_foreign_state')? __$('person_home_foreign_state').value : "??");
			        td.style.textAlign = "left";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML = "District: ";
			        td.style.fontWeight = "bold";
			        td.style.textAlign = "right";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML = (__$('person_home_foreign_district')? __$('person_home_foreign_district').value : "??");
			        td.style.textAlign = "left";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.innerHTML = "Village: ";
			        td.style.borderBottom = "1px solid black";
			        td.style.fontWeight = "bold";
			        td.style.textAlign = "right";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.innerHTML = (__$('person_home_foreign_village')? __$('person_home_foreign_village').value : "??");
			        td.style.textAlign = "left";
			        td.style.borderBottom = "1px solid black";
			        td.colSpan ="2";
			        tr.appendChild(td);
			    }

		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        var td = document.createElement("td");
		        td.style.border = "1px solid black";
		        td.innerHTML = "11";
		        td.style.textAlign = "right";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.colSpan ="9";
		        td.style.border = "none";
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML = "In case this is a female death, did the death occur while pregnant, at the time of delivery or within 6 weeks after the end of pregnancy?";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		         td.style.borderBottom = "1px solid black";
		        td.innerHTML =(__$("person_died_while_pregnant") && __$("person_died_while_pregnant").value ? __$('person_died_while_pregnant').value : "N/A");
		        tr.appendChild(td);

		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        var td = document.createElement("th");
		        td.style.border = "1px solid black";
		        td.innerHTML = "Part 2 <br/> DETAILS OF PARENTS";
		        td.rowSpan ="4"
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "1px solid black";
		        td.innerHTML = "1";
		        td.style.textAlign = "right";
		        td.rowSpan ="2"
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.fontWeight = "bold";
		        td.innerHTML = "Mother's name";
		        td.colSpan ="11";
		        tr.appendChild(td);

		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.borderBottom = "1px solid black";
		        td.style.fontWeight = "bold";
		        td.innerHTML = "Surname";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		         td.style.borderBottom = "1px solid black";
		        td.innerHTML =( __$("person_mother_last_name") && __$("person_mother_last_name").value ? __$('person_mother_last_name').value : "");
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.borderBottom = "1px solid black";
		        td.style.fontWeight = "bold";
		        td.innerHTML = "First name ";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML = (__$("person_mother_first_name") && __$("person_mother_first_name").value ? __$('person_mother_first_name').value : "");
		        tr.appendChild(td);

		         var td = document.createElement("td");
		        td.style.border = "none";
		         td.style.borderBottom = "1px solid black";
		        td.style.fontWeight = "bold";
		        td.innerHTML = "Other names ";
		        td.colSpan ="2";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		         td.style.borderBottom = "1px solid black";
		        td.innerHTML = (__$("person_mother_middle_name") && __$("person_mother_middle_name").value ? __$('person_mother_middle_name').value : "");
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML = "2";
		        td.style.textAlign = "right";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.borderBottom = "1px solid black";
		        td.style.fontWeight = "bold";
		        td.innerHTML = "ID No.";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML = (__$("person_mother_id_number") && __$("person_mother_id_number").value ? __$('person_mother_id_number').value : "");
		        tr.appendChild(td);

		         var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        var td = document.createElement("td");
		        td.style.border = "none";
		         td.style.border = "1px solid black";
		        td.innerHTML = "3";
		        td.style.textAlign = "right";
		        td.rowSpan ="2"
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.fontWeight = "bold";
		        td.innerHTML = "Father's name";
		        td.colSpan ="11";
		        tr.appendChild(td);

		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.fontWeight = "bold";
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML = "Surname";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "none";
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML = (__$("person_father_last_name") && __$("person_father_last_name").value ? __$('person_father_last_name').value : "");
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.fontWeight = "bold";
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML = "First name ";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML = (__$("person_father_first_name") && __$("person_father_first_name").value ? __$('person_father_first_name').value : "");
		        tr.appendChild(td);

		         var td = document.createElement("td");
		        td.style.fontWeight = "bold";
		         td.style.borderBottom = "1px solid black";
		        td.innerHTML = "Other names";
		        td.colSpan ="2";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML = (__$("person_father_middle_name") && __$("person_father_middle_name").value ? __$('person_father_middle_name').value : "");
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.innerHTML = "4";
		        td.style.textAlign = "right";
		        td.style.borderBottom = "1px solid black";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.borderBottom = "1px solid black";
		        td.style.fontWeight = "bold";
		        td.innerHTML = "ID No.";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML = __$("person_father_id_number") && __$("person_father_id_number").value ? __$('person_father_id_number').value : "";
		        tr.appendChild(td);

		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        var td = document.createElement("th");
		        td.innerHTML = "Part 3 <br/> DETAILS OF INFORMANT";
		        td.rowSpan ="7"
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.border = "1px solid black";
		        td.innerHTML = "1";
		        td.style.textAlign = "right";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.fontWeight = "bold";
		        td.innerHTML = "Surname";
		         td.style.borderBottom = "1px solid black";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML = (__$("person_informant_last_name") &&__$("person_informant_last_name").value ? __$('person_informant_last_name').value : "");
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.fontWeight = "bold";
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML = "First name ";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.innerHTML = (__$("person_informant_first_name") && __$("person_informant_first_name").value ? __$('person_informant_first_name').value : "");
		       	 td.style.borderBottom = "1px solid black";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.fontWeight = "bold";
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML = "Other names";
		        td.colSpan ="2";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.innerHTML = (__$("person_informant_middle_name") && __$("person_informant_middle_name").value ? __$('person_informant_middle_name').value : "");
		        td.style.borderBottom = "1px solid black";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.innerHTML = "2";
		         td.style.borderBottom = "1px solid black";
		        td.style.textAlign = "right";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.fontWeight = "bold";
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML = "ID No.";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML = (__$("person_informant_id_number") && __$("person_informant_id_number").value ? __$('person_informant_id_number').value : "");
		        tr.appendChild(td);

		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        var td = document.createElement("td");
		        td.style.border = "1px solid black";
		        td.innerHTML = "3";
		        td.style.textAlign = "right";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.innerHTML = "Relationship to the deceased";
		         td.style.borderBottom = "1px solid black";
		        td.style.fontWeight = "bold";
		        td.colSpan ="2";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.borderBottom = "1px solid black";
		        td.colSpan ="8";
		        td.innerHTML = (__$("person_informant_relationship_to_deceased") && __$("person_informant_relationship_to_deceased").value ? __$('person_informant_relationship_to_deceased').value : "");
		        tr.appendChild(td);

		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        var td = document.createElement("td");
		        td.style.border = "1px solid black";
		        td.innerHTML = "4";
		        td.style.textAlign = "right";
		        td.rowSpan ="2";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.fontWeight = "bold";
		         td.style.borderBottom = "1px solid black";
		        td.innerHTML = "Address";
		        tr.appendChild(td);

				if(__$('person_informant_current_country') && __$('person_informant_current_country').value.trim().toLowerCase()=="malawi"){	        	
					var td = document.createElement("td");
			        td.style.fontWeight = "bold";
			        td.innerHTML = "District : ";
			        td.style.borderBottom = "1px solid black";
			        tr.appendChild(td);
	
			        var td = document.createElement("td");
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML =(__$("person_informant_current_district") && __$("person_informant_current_district").value ? __$('person_informant_current_district').value : "");
			        tr.appendChild(td);
	
			        var td = document.createElement("td");
			        td.style.fontWeight = "bold";
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML = "TA : ";
			        tr.appendChild(td);
	
			        var td = document.createElement("td");
			        td.style.borderBottom = "1px solid black";
			        if(__$('person_informant_current_ta')){
			        	if(__$("person_informant_current_ta").value == "Other"){
			        		td.innerHTML =__$("person_other_informant_current_ta").value;
			        	}else{
			        		td.innerHTML =__$("person_informant_current_ta").value;
			        	}
			        }
			        tr.appendChild(td);
	
			        var td = document.createElement("td");
			        td.style.fontWeight = "bold";
			        td.innerHTML = "Village :";
			        td.style.borderBottom = "1px solid black";
			        tr.appendChild(td);
	
			        var td = document.createElement("td");
			        td.style.borderBottom = "1px solid black";
			        td.colSpan ="5";
			        if(__$('person_informant_current_village')){
			        	if(__$("person_informant_current_village").value == "Other"){
			        		td.innerHTML =__$("person_other_informant_current_village").value;
			        	}else{
			        		td.innerHTML =__$("person_informant_current_village").value;
			        	}
			        }
			        tr.appendChild(td);
			    }else{
					var td = document.createElement("td");
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML = "Country:";
			        td.style.fontWeight = "bold";
			        td.style.textAlign = "right";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML = (__$('person_informant_current_country')? __$('person_informant_current_country').value : "??");
			        td.style.textAlign = "left";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.innerHTML = "State : ";
			        td.style.textAlign = "right";
			        td.style.borderBottom = "1px solid black";
			        td.style.fontWeight = "bold";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML = (__$('person_informant_foreign_state')? __$('person_informant_foreign_state').value : "??");
			        td.style.textAlign = "left";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML = "District : ";
			        td.style.fontWeight = "bold";
			        td.style.textAlign = "right";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.style.borderBottom = "1px solid black";
			        td.innerHTML = (__$('person_informant_foreign_district')? __$('person_informant_foreign_district').value : "??");
			        td.style.textAlign = "left";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.innerHTML = "Village : ";
			        td.style.borderBottom = "1px solid black";
			        td.style.fontWeight = "bold";
			        td.style.textAlign = "right";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.innerHTML = (__$('person_informant_foreign_village')? __$('person_informant_foreign_village').value : "??");
			        td.style.textAlign = "left";
			        td.style.borderBottom = "1px solid black";
			        td.colSpan ="2";
			        tr.appendChild(td);			    	
			    }

		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        var td = document.createElement("td");
		        td.innerHTML = "Postal address";
		        td.style.borderBottom = "1px solid black";
		        td.style.fontWeight = "bold";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.borderBottom = "1px solid black";
		        td.colSpan ="2";
		        var address = (__$('person_informant_addressline1') && __$('person_informant_addressline1').value ? __$('person_informant_addressline1').value  : "");
		        address = (__$('person_informant_city') && __$('person_informant_city').value ? address + __$('person_informant_city').value : address);
		        td.innerHTML = address;
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.innerHTML = "Telephone number";
		        td.colSpan ="2";
		        td.style.borderBottom = "1px solid black";
		        td.style.fontWeight = "bold";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.innerHTML = (__$("person_informant_phone_number") && __$("person_informant_phone_number").value ? __$("person_informant_phone_number").value : "");
		        td.colSpan ="4";
		        td.style.borderBottom = "1px solid black";
		        tr.appendChild(td);

		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        var td = document.createElement("td");
		        td.style.border = "1px solid black";
		        td.innerHTML = "5";
		        td.style.textAlign = "right";
		        td.rowSpan = "3"
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.borderBottom = "1px solid black";
		        td.colSpan= "10"
		        td.innerHTML = "I certify that the above information is correct and I am aware that I could face criminal prosecution if this information is incorrect in material respect.";
		        tr.appendChild(td);

		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        var td = document.createElement("td");
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML = "Informant Signed";
		        td.style.fontWeight = "bold";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.style.borderBottom = "1px solid black";
		        td.colSpan= "10"
		        td.innerHTML = (__$("person_informant_signed") && __$("person_informant_signed").value ? __$('person_informant_signed').value : "No");
		        tr.appendChild(td);

		        var tr = document.createElement("tr");
		        tableContent.appendChild(tr);
		        td.style.borderBottom = "1px solid black";
		        var td = document.createElement("td");
		        td.style.fontWeight = "bold";
		        td.innerHTML = "Date informant signed";
		        tr.appendChild(td);

		        var td = document.createElement("td");
		        td.colSpan= "10"
		        td.style.borderBottom = "1px solid black";
		        td.innerHTML =(__$("person_informant_signature_date") && __$("person_informant_signature_date").value ? (new Date( __$('person_informant_signature_date').value)).format() : "");
		        tr.appendChild(td);

		    }
		    if (site_type == "dc"){
		    		var table = document.createElement("table");
		    		table.style.width = "98%";
			        table.style.borderCollapse = "collapse";
			        table.cellPadding = "2";
			        table.style.border = "1px solid black"
			        table.style.fontSize = "1em";
			        table.style.margin = "auto";
			        table.style.marginTop ="2em";
			        div.appendChild(table);

			        var tr = document.createElement("tr");
			        table.appendChild(tr);

			        var td = document.createElement("th");
			        td.innerHTML = "Verification by Village Headman";
			        td.colSpan ="2";
			        tr.appendChild(td);

			        var tr = document.createElement("tr");
			        table.appendChild(tr);

			        var td = document.createElement("td");
			        td.innerHTML = "Villge Headman/Block Leader Signed";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.innerHTML = (__$('person_headman_verified') ? __$('person_headman_verified').value : "");
			        tr.appendChild(td);

			        if (__$('person_headman_verified') && __$('person_headman_verified').value.trim().toLowerCase()=="yes"){
			        	var tr = document.createElement("tr");
			        	table.appendChild(tr);
			        	var td = document.createElement("td");
				        td.innerHTML = "Date Signed";
				        tr.appendChild(td);

				        var td = document.createElement("td");
				        td.innerHTML = new Date(__$('person_headman_verification_date').value).format();
				        tr.appendChild(td);
			        }

			        var table = document.createElement("table");
		    		table.style.width = "98%";
			        table.style.borderCollapse = "collapse";
			        table.cellPadding = "2";
			        table.style.border = "1px solid black"
			        table.style.fontSize = "1em";
			        table.style.margin = "auto";
			        table.style.marginTop ="2em";
			        div.appendChild(table);
			        var tr = document.createElement("tr");
			        table.appendChild(tr);

			        var td = document.createElement("th");
			        td.innerHTML = "Verification by Senior member of village/ Religous Institution";
			        td.colSpan ="2";
			        tr.appendChild(td);

			        var tr = document.createElement("tr");
			        table.appendChild(tr);

			        var td = document.createElement("td");
			        td.innerHTML = "Signed?";
			        tr.appendChild(td);

			        var td = document.createElement("td");
			        td.innerHTML = (__$('person_church_verified') ? __$('person_church_verified').value : "");
			        tr.appendChild(td);

			        if (__$('person_church_verified') && __$('person_church_verified').value.trim().toLowerCase()=="yes"){
			        	var tr = document.createElement("tr");
			        	table.appendChild(tr);
			        	var td = document.createElement("td");
				        td.innerHTML = "Date Signed";
				        tr.appendChild(td);

				        var td = document.createElement("td");
				        td.innerHTML = new Date(__$('person_church_verification_date').value).format();
				        tr.appendChild(td);
			        }

		   	}

		   	var place_of_death = (__$('person_place_of_death') && __$('person_place_of_death').value ? __$('person_place_of_death').value : "");
		   	place_of_death = (__$('person_place_of_death_foreign') && __$('person_place_of_death_foreign').value ? __$('person_place_of_death_foreign').value : place_of_death);

		   	if(place_of_death.trim() == 'Home'){
		   		__$('home').checked = true
		   		__$('home').setAttribute('disabled','disabled');
		   		__$('facility').setAttribute('disabled','disabled')
		   		__$('other').setAttribute('disabled','disabled')
		   	}
		   	if(place_of_death.trim().toLowerCase().match('facility')){
		   		__$('facility').checked = true
		   		__$('home').setAttribute('disabled','disabled');
		   		__$('facility').setAttribute('disabled','disabled')
		   		__$('other').setAttribute('disabled','disabled')
		   	}
		   	if(place_of_death.trim().toLowerCase().match('other')){
		   		__$('other').checked = true
		   		__$('home').setAttribute('disabled','disabled');
		   		__$('facility').setAttribute('disabled','disabled')
		   		__$('other').setAttribute('disabled','disabled')
		   	}
		}
		function setAjaxUrl(case_number){
			switch(case_number) {
				case -1:
					var place = __$('touchscreenInput' + tstCurrentPage).value;
					__$("person_place_of_death_district").setAttribute("ajaxURL","/districts?place="+encodeURIComponent(place)+"&search_string=");
					break;

				case 0:
					var district = __$('touchscreenInput' + tstCurrentPage).value;
					if(__$("person_hospital_of_death")){
						__$("person_hospital_of_death").setAttribute("ajaxURL","/facilities?district="+district+"&search_string=");
					}
					if(__$("person_place_of_death_ta")){
					    __$("person_place_of_death_ta").setAttribute("ajaxURL","/tas?district="+district+"&search_string=");
					}
					break;

				case 1:
					var ta = __$('touchscreenInput' + tstCurrentPage).value;
					var district = __$('person_place_of_death_district').value
					__$("person_place_of_death_village").setAttribute("ajaxURL","/villages?district="+district+"&ta="+ta + "&search_string=")
					break;

					    case 2:
					    	var district = __$('touchscreenInput' + tstCurrentPage).value;
					      	__$("person_home_ta").setAttribute("ajaxURL","/tas?district="+district + "&search_string=")
					    	break;

					    case 3:

					    	var ta = __$('touchscreenInput' + tstCurrentPage).value;

					    	var district = __$('person_home_district').value

					    	__$("person_home_village").setAttribute("ajaxURL","/villages?district="+district+"&ta="+ta + "&search_string=")

					        break;
					    case 4:

					    	var district = __$('touchscreenInput' + tstCurrentPage).value;

					      	__$("person_informant_current_ta").setAttribute("ajaxURL","/tas?district="+district + "&search_string=")

					    	break;

					    case 5:

					    	var ta = __$('touchscreenInput' + tstCurrentPage).value;

					    	var district = __$('person_informant_current_district').value

					    	__$("person_informant_current_village").setAttribute("ajaxURL","/villages?district="+district+"&ta="+ta + "&search_string=")

					        break;

					     case 6:

					    	var district = __$('touchscreenInput' + tstCurrentPage).value;

					      	__$("person_current_ta").setAttribute("ajaxURL","/tas?district="+district + "&search_string=")

					    	break;

					    case 7:

					    	var ta = __$('touchscreenInput' + tstCurrentPage).value;

					    	var district = __$('person_current_district').value

					    	__$("person_current_village").setAttribute("ajaxURL","/villages?district="+district+"&ta="+ta + "&search_string=")

					        break;
				} 

		}
		var confirmation = null;
		var confirmationTimeout = null
		function hideConfirmation(){
		    if (confirmation != null) confirmation.setAttribute('style', 'display:none');
		    if (confirmationTimeout != null) window.clearTimeout(confirmationTimeout);
		}
		function cancelForm(){
			hideConfirmation();
			//window.top.location.href ="/people/new_person_type";
		}
		function confirmYesNo(message, yes, no,time) {
		    hideConfirmation();

		    if (confirmation == null) {
		        confirmation = document.createElement("div");
		        confirmation.setAttribute('id', 'confirmation');
		        
		        document.body.appendChild(confirmation);
		    }
		    confirmation.innerHTML = ''+
		    '<div class="confirmation" >'+ message+ '<div>'+
		    '<button id="yes"><span>Yes</span></button>'+
		    '<button id="no"><span>No</span></button></div>'+
		    '</div>';

		    if(yes){
		    	__$("yes").onmousedown = yes;   
		    }
		    
		    if(no){
		    	__$("no").onmousedown = no;
		    }else{
		    	__$("yes").innerHTML ="OK"
		    	__$("no").style.display ="none";
		    }
		    
		    
		    confirmation.setAttribute('style', 'display:block');
		    if(time){

		    	confirmationTimeout = window.setTimeout("hideConfirmation()", time);
		    }else{
		    	confirmationTimeout = window.setTimeout("hideConfirmation()", 5000);
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

		    __$("person_date_of_death").setAttribute("minDate", birthdate);

		    __$("person_date_of_death").setAttribute("maxDate", (new Date().format("YYYY-mm-dd")));
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

		            //console.log( __$("person_birthdate").value);

		        } else {

		            __$("person_birthdate_estimated").value = 0;

		        }

		    }

		}

		function validateAndProcessMonth() {

		    var year = __$("person_birth_year").value

		    var month = __$('person_birth_month').value;

		    if (month.trim().toLowerCase() == "unknown") {


		        var birthdate = __$("person_birthdate");

		        var estimate_field = (birthdate.getAttribute("estimate_field") != null ?
		            __$(birthdate.getAttribute("estimate_field")) : undefined);

		        if (estimate_field) {

		            estimate_field.value = 1

		        }

		        var estimateBirthDate = year + "-07-10";

		        birthdate.value = estimateBirthDate

		        __$("estimate").value = 1;

		    } else {

		        var months = {
		            "January": 0,
		            "February": 1,
		            "March": 2,
		            "April": 3,
		            "May": 4,
		            "June": 5,
		            "July": 6,
		            "August": 7,
		            "September": 8,
		            "October": 9,
		            "November": 10,
		            "December": 11
		        }

		        var today = new Date();

		        if (parseInt(year) == parseInt(today.getFullYear()) && parseInt(months[month]) > parseInt(today.getMonth())) {

		            var message = "Month selected is greater than Current Month";

		            setTimeout(function () {

		                gotoPage(tstCurrentPage - 1, false, true);

		                showMessage(message,null,30000);

		            }, 10);

		        }

		    }

		}
		function checkForDuplicate(){

				var place_of_death = (__$("person_place_of_death") && __$("person_place_of_death").value? __$("person_place_of_death").value : "" );
				place_of_death = (__$("person_place_of_death_foreign") && __$("person_place_of_death_foreign").value? __$("person_place_of_death_foreign").value : place_of_death);	
				var place_of_death_district = (__$("person_place_of_death_district") ? __$("person_place_of_death_district").value : "Abroad")
				place_of_death_district  = (__$("place_of_death_foreign_district") ? __$("place_of_death_foreign_district").value : place_of_death_district)
				var data = {
								first_name    			: __$("person_first_name").value,
								last_name 	  			: __$("person_last_name").value,
								middle_name         	: __$("person_middle_name").value,
								gender 		  			: __$("person_gender").value,
								birthdate 	  			: __$("person_birthdate").value,
								date_of_death 			: __$("person_date_of_death").value,
								place_of_death 			: place_of_death,
								place_of_death_district : place_of_death_district,
								informant_last_name 	: __$("person_informant_last_name").value,
								informant_first_name 	: __$("person_informant_first_name").value
				}
				//console.log(data)
				postAjax("/search_similar_record", data, function(response){
					var results = JSON.parse(response);
					if(results.response){
						duplicatesPopup(results)
					}
				})
		}

		function removeUnknown(){

			__$("Unknown").style.display ="none";
		}

		var patnum = ""
		var setFocusTimeout = 5000;
		var checkForBarcodeTimeout = 1500;
		var barcodeFocusTimeoutId = null;
		var barcodeFocusOnce = false;
		var barcodeId = '';
		var focusOnce = false;
		var barcode_element;
		var checkBarcodeInterval ;
		function loadBarcodePage() {

			focusForBarcodeInput()
		 	checkBarcodeInterval = setInterval(function(){

		 		 checkForBarcode();
		 	},200);

		}

		function focusForBarcodeInput(){

			if (!barcodeId) {
				barcodeId = "person_barcode";
			}

		  	barcode_element = document.getElementById(barcodeId);

			if (barcode_element) {
				barcode_element.focus();
				if (!focusOnce) barcodeFocusTimeoutId = window.setTimeout("focusForBarcodeInput()", setFocusTimeout);
			}
		}

		function checkForBarcode(validAction){

			if (__$("person_barcode")){

				var input_element = __$('touchscreenInput' + tstCurrentPage);

				if (input_element && input_element.value.match(/.+\$$/i) != null){
					 barcode_element.value = input_element.value.substring(0,input_element.value.length-1);
					 if(isNaN(barcode_element.value)){
						showMessage("The barcode number <b>("+barcode_element.value + ")</b> contains letters");
						setTimeout(function(){
							window.location.reload();
						},1500);
					}else{
						checkBarcode();
					 	gotoNextPage();	
					 	clearInterval(checkBarcodeInterval)
					}								
				}
			}
		}

		function checkBarcode(){
			var value = __$('touchscreenInput' + tstCurrentPage).value;
			if (value && value.match(/.+\$$/i) != null){
				value = value.substring(0,value.length-1);
				
			}
			postAjax("/search_barcode",{barcode : value},function(response){
				var response = JSON.parse(response).response
				if(response){
					confirmYesNo("Scanned Barcode ("+value+") already exist for another record",
						function(){
							top.location.reload();
						},
						function(){
							top.location ="/people/view/"+response+"?next_url=/people/new_person_type";
						},300000);
					__$("yes").innerHTML ="Dismiss"
					__$("yes").className = "red";
					__$("no").innerHTML ="View Record"
					setTimeout(function(){
						gotoPage(tstCurrentPage -1);
					},100);
				}
			});								
		}

		window.addEventListener("load", loadBarcodePage, false);

		function getAge(dateString,otherDate){

		    var today = new Date();

		    if(otherDate){
		    	today = new Date(otherDate);
		    }

		    var birthDate = new Date(dateString);

		    var age = today.getFullYear() - birthDate.getFullYear();

		    var m = today.getMonth() - birthDate.getMonth();

		    if(parseInt(__$('person_birthdate_estimated').value) == 0){
		    	if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) 
			    {
			        age--;
			    }
		    }
		    return age;
		}

		function validatePregnancy(){

			var age = parseInt(getAge(__$('person_birthdate').value, __$('person_date_of_death').value));

			if(__$("person_gender") && __$("person_gender").value == "Male"){
				return false;
			}
			if (__$('person_birthdate') && parseInt(getAge(__$('person_birthdate').value)) >= 9 && parseInt(getAge(__$('person_birthdate').value)) <= 55){
				return true;
			}else{
				 return false;
			}

		}

		var flag = true;
		function flagIfOut(){
				if(flag){
					var value = __$('touchscreenInput' + tstCurrentPage).value;
					var age = parseInt(getAge(__$('person_birthdate').value, __$('person_date_of_death').value));
					if(value.trim() == "Yes"){
						if(__$("person_gender") && __$("person_gender").value == "Female" && __$('person_birthdate') && ((age >= 9 && age <= 13) ||  (age >= 50 && age <= 55))){
							confirmYesNo("Female is out of the normal child bearing age range <br><b>(13 - 49)</b>",
								function(){
									__$("confirmation").style.display ="none";
								},
								function(){
									flag = false;
									gotoNextPage();
									__$("confirmation").style.display ="none";
								},300000);

							__$("yes").innerHTML ="Change"
							__$("no").innerHTML ="Continue";
							setTimeout(function(){
								gotoPage(tstCurrentPage -1);
							},100);
						}
					}
				}else{

				}
		}

		function validateDeathDate(){
			var date  = __$('touchscreenInput' + tstCurrentPage).value;
			date = (new Date(date)).format("YYYY-mm-dd");
			var today = new Date();
			today = today.format("YYYY-mm-dd");
			if (date > today){
				showMessage("Date of death entered ("+ (new Date(date)).format()+") is greater than today "+(new Date(today)).format(),null,30000);
				setTimeout(function(){
					gotoPage(tstCurrentPage -1);
				},100)
			}
			var min = new Date();
			min.setDate(-42);
			min = min.format("YYYY-mm-dd");
			var birthdate = (new Date(__$("person_birthdate").value)).format("YYYY-mm-dd");

			if(date < birthdate){
				showMessage("Birth date ("+(new Date(__$("person_birthdate").value)).format()+") is greater than <br/> Date of death ("+(new Date(date)).format() +")",null,30000);
				setTimeout(function(){
					gotoPage(tstCurrentPage -1);
				},100)

				return;
			}
			if(site_type == "facility"){
					
					if (date < min){
						confirmYesNo("Registration of the record has been delayed by more than 6 weeks <br><b>please send the form to DRO</b>",function(){cancelForm()},null,30000);
						setTimeout(function(){
							gotoPage(tstCurrentPage -1);
						},100);
					}
			}else{

				if(date < min){
					showMessage("Registration of the record has been delayed by more than 6 weeks",null,30000);
					__$("person_delayed_registration").value ="Yes"
				}
			}
			
		}

		function validateDateInformant(){
			var date  = __$('touchscreenInput' + tstCurrentPage).value;
			date = new Date(date).format("YYYY-mm-dd");
			var today = new Date();
			today = today.format("YYYY-mm-dd");
			if (date > today){
				showMessage("Date entered ("+ (new Date(date)).format()+") is greater than today "+(new Date(today)).format(),null,30000);
				setTimeout(function(){
					gotoPage(tstCurrentPage -1);
				},100)
			}
			min = new Date( __$("person_date_of_death").value).format("YYYY-mm-dd")
			if(date < min){
				showMessage("Death date ("+(new Date(__$("person_date_of_death").value)).format()+") is greater than <br/> Date informant signed ("+(new Date(date)).format() +")",null,30000);
				setTimeout(function(){
					gotoPage(tstCurrentPage -1);
				},100)
			}
		}

		function validateWithDeathDate(){
			var date  = __$('touchscreenInput' + tstCurrentPage).value;
			date = new Date(date).format("YYYY-mm-dd");
			var today = new Date();
			today = today.format("YYYY-mm-dd");
			if (date > today){
				showMessage("Date  entered ("+ (new Date(date)).format()+") is greater than today "+(new Date(today)).format(),null,30000);
				setTimeout(function(){
					gotoPage(tstCurrentPage -1);
				},100)
			}
			min = new Date( __$("person_date_of_death").value).format("YYYY-mm-dd");
			if(date < min){
				showMessage("Death date ("+(new Date(__$("person_date_of_death").value)).format()+") is greater than <br/> Date signed ("+(new Date(date)).format() +")",null,30000);
				setTimeout(function(){
					gotoPage(tstCurrentPage -1);
				},100)
			}
		}

		var cont = {}
		function validateName(person,level){
			var input  = __$('touchscreenInput' + tstCurrentPage).value.trim();
			var regex = /^[a-zA-Z']{2,24}$/;
			var name_length = (__$(person+'_last_name') ? __$(person+'_last_name').value.length : "") + 
							(__$(person+'_first_name') ?  __$(person+'_first_name').value.length : "");
			if(__$(person+'_middle_name') && __$(person+'_middle_name').value.length > 0){
					name_length = name_length + __$(person+'_middle_name').value.split(" ").join("").length;
			}
			if(input.length > 0 ){
				if (regex.test(input)){				        
				}else if(parseInt(name_length) > 42){
					showMessage("Name of the deceased has "+name_length+" character(s) which is more than 42 characters ",null,60000);
					setTimeout(function(){
						gotoPage(tstCurrentPage -1);
					},200);
				}else {
				 	var check_number_regex = /\d/;
				 	var check_space_regex = /\s/;
				 	var special_characters =  /[-!$%^&*()_+|~=`{}\[\]:";<>?,.\/]/
				 	if(check_number_regex.test(input)){
				 		showMessage("The name contains number(s)",null,30000);
				 	}else if(check_space_regex.test(input)){
				 		showMessage("The name contains space(s) it should be one word",null,30000);
				 	}else if(special_characters.test(input)){
				 		showMessage("The name should not contains special character(s)",null,30000);
				 	}else{	
				 		if(!cont[level]){
				 			confirmYesNo("Name has "+input.length + " characters but recommended is atmost 24 characters",
						 		function(){
						 			hideConfirmation();
						 		},function(){
						 			hideConfirmation();
						 			cont[level] = true;
						 			gotoNextPage();
						 		},30000);
				 			__$("yes").innerHTML ="Change"
							__$("no").innerHTML ="Continue";
				 			}				 				
				 		}
				 		if(!cont[level]){
				 			setTimeout(function(){
								gotoPage(tstCurrentPage -1);
							},100);
				 		}				 		
				  }
			}
			clearInterval(spaceInterval);
		}

		function validateOtherName(person,level){

			var input  = __$('touchscreenInput' + tstCurrentPage).value;
			var regex = /^[a-zA-Z' ]{2,42}$/;
			var name_length = __$(person+'_last_name').value.length + 
								  __$(person+'_first_name').value.length;
			if(__$(person+'_middle_name').value.length > 0){
					name_length = name_length + __$(person+'_middle_name').value.split(" ").join("").length;
			}
			if(input.length > 0 ){
				if (regex.test(input)){				        
				}else if(parseInt(name_length) > 42){
					showMessage("Name of the deceased has "+name_length+" character(s) which is more than 42 characters",null,60000);
					setTimeout(function(){
						gotoPage(tstCurrentPage -1);
					},200);
				}else {
				 	var check_number_regex = /\d/;
				 	var check_space_regex = /\s/;

				 	if(check_number_regex.test(input)){
				 		showMessage("The name contains number(s)",null,30000);
				 	}else{	
				 		if(!cont[level]){
				 			confirmYesNo("Name has "+input.length + " characters but recommended is atmost 24 characters",
						 		function(){
						 			hideConfirmation();
						 		},function(){
						 			hideConfirmation();
						 			cont[level] = true;
						 			gotoNextPage();
						 		},30000);
				 			__$("yes").innerHTML ="Change"
							__$("no").innerHTML ="Continue";
				 			}				 				
				 		}
				 		if(!cont[level]){
				 			setTimeout(function(){
								gotoPage(tstCurrentPage -1);
							},100);
				 		}				 		
				  }
			}
			clearInterval(spaceInterval);
		}

		function setOtherTofield(id){
			__$(id).value = "Other"
		}

		function courtOrder(){
			var order = __$('touchscreenInput'+tstCurrentPage).value;
			if(order=="No"){
					confirmYesNo("Registering missing person requires a court order",function(){cancelForm()},null,30000);
					setTimeout(function(){
							gotoPage(tstCurrentPage -1);
					},100);
			}
		}

		function policeReport(registration_type){
			var order = __$('touchscreenInput'+tstCurrentPage).value;
			if(order=="No"){
					confirmYesNo("Registering "+(registration_type ? registration_type : "Unnatural death")+" requires a police report",function(){cancelForm()},null,30000);
					setTimeout(function(){
							gotoPage(tstCurrentPage -1);
					},100);
			}
		}
		
		function removeDollar(){
			var input_element = __$('touchscreenInput' + tstCurrentPage);
			if (input_element && input_element.value.match(/.+\$$/i) != null){
				 setTimeout(function(){
						barcode_element.value = input_element.value.substring(0,input_element.value.length-1);
				},1000);		
			}
			else{
				//console.log("No dollar");
			}
		}

results = {}
old_value = "";
function showPhoneSummary(){
            //variables 'results' and 'old_value' must be predefined above this function
    var input = __$("touchscreenInput" + tstCurrentPage);
    var label = __$("helpText" + tstCurrentPage).innerHTML;

    if (label.match(/Phone Number/i)){

                //Lock Next
        if (input.value == "Unknown" || results['valid'] == true) {
            __$("nextButton").onmousedown = function () {
                        gotoNextPage();
        	}
        }else{
            __$("nextButton").onmousedown = function () {
                        var label = __$("helpText" + tstCurrentPage).innerHTML;
                        if (label.match(/Phone Number/i)){
                            showMessage("Invalid Phone Number",null,30000);
                        }else{
                            gotoNextPage();
                        }
            }
        }

        if (input.value != "Unknown" && (input.value.trim().length == 0 || !input.value.match(/^\+/))){
                    input.value = "+265";
        }

         if(old_value != input.value) {

            var val = input.value.replace(/\+/, 'plus');

            if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
                        xmlhttp = new XMLHttpRequest();
            } else {// code for IE6, IE5
                        xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
            }

            xmlhttp.onreadystatechange = function () {
                if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                            results = xmlhttp.responseText;
                            results = JSON.parse(results);
                            var national_format = results['national_format'] || "<span style='color: red'>?</span>";
                            var international_format = results['international_format'] || "<span style='color: red'>?</span>";
                            var country = results['country'] || "<span style='color: red'>?</span>";

                            var div = document.createElement("div");
                            div.id = "status";
                            div.className = "statusLabel";
                            div.style.marginTop = "2%";
                            div.style.fontSize = "1.7em";
                            div.style.padding = "12px";
                            div.style.textAlign = "left";
                            div.innerHTML = "National format:&nbsp;&nbsp;&nbsp;<i style='color: green;'> " + national_format + "</i>" +
                                    "<br />International format: &nbsp;&nbsp;&nbsp;<i style='color: green;'>" + international_format + "</i>" +
                                     "<br />Country: &nbsp;&nbsp;&nbsp;<i style='color: green;'>" + country + "</i> "
                            __$("inputFrame" + tstCurrentPage).appendChild(div);
                        }
                }

                xmlhttp.open("GET", ("/global_phone_validation?value="+val), true);
                xmlhttp.send();
            }

            old_value = input.value;

            setTimeout("showPhoneSummary()",200);
        }
 }

 var spaceInterval ;
 function checkSpace(){
 	//__$('touchscreenInput'+tstCurrentPage).className = __$('touchscreenInput'+tstCurrentPage).className+ " capitalize";
 	spaceInterval = setInterval(function(){
 		var text_input = __$('touchscreenInput'+tstCurrentPage).value
	 	if(text_input.length > 0){
	 		__$('touchscreenInput'+tstCurrentPage).value = text_input.capitalize();
	 	}		
 	},20);
 	
 }







        