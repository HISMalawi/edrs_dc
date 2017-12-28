Object.defineProperty(Date.prototype, "format", {
   value: function (format) {
           var date = this;
           var result = "";

           if (!format) {

                        format = ""

           }

            var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

            var monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September",
                        "October", "November", "December"];

            if (format.match(/YYYY\-mm\-dd/)) {

                        result = date.getFullYear() + "-" + padZeros((parseInt(date.getMonth()) + 1), 2) + "-" + padZeros(date.getDate(), 2);

            } else if (format.match(/mmm\/d\/YYYY/)) {

                        result = months[parseInt(date.getMonth())] + "/" + date.getDate() + "/" + date.getFullYear();

            } else if (format.match(/d\smmmm,\sYYYY/)) {

                        result = date.getDate() + " " + monthNames[parseInt(date.getMonth())] + ", " + date.getFullYear();

            } else {

                        result = date.getDate() + "/" + months[parseInt(date.getMonth())] + "/" + date.getFullYear();

            }

                    return result;
           }
});


function $$(id){
    return document.getElementById(id);
}

function showPopupMessage(msg, topic,targeturl) {

                if (!topic) {

                    topic = "Message";

                }

                var shield = document.createElement("div");
                shield.style.position = "absolute";
                shield.style.top = "0px";
                shield.style.left = "0px";
                shield.style.width = "100%";
                shield.style.height = "100%";
                shield.id = "msg.shield";
                shield.style.backgroundColor = "rgba(128,128,128,0.5)";
                shield.style.zIndex = 1050;

                document.body.appendChild(shield);

                var width = 560;
                var height = 200;

                var div = document.createElement("div");
                div.id = "msg.popup";
                div.style.position = "absolute";
                div.style.width = width + "px";
                div.style.height = height + "px";
                div.style.backgroundColor = "#eee";
                div.style.border = "1px solid #26262b"
                div.style.borderRadius = "1px";
                div.style.left = "calc(50% - " + (width / 2) + "px)";
                div.style.top = "calc(50% - " + (height * 0.7) + "px)";
                div.style.border = "1px outset #fff";
                div.style.boxShadow = "5px 2px 5px 0px rgba(0,0,0,0.75)";
                div.style.fontFamily = "arial, helvetica, sans-serif";
                div.style.MozUserSelect = "none";

                shield.appendChild(div);

                var table = document.createElement("table");
                table.width = "100%";
                table.cellSpacing = 0;

                div.appendChild(table);

                var trh = document.createElement("tr");

                table.appendChild(trh);

                var th = document.createElement("th");
                th.style.padding = "5px";
                th.style.borderTopRightRadius = "1px";
                th.style.borderTopLeftRadius = "1px";
                th.style.fontSize = "20px";
                th.style.backgroundColor = "#345db5";
                th.style.color = "#fff";
                th.id ="msg.topic"
                th.innerHTML = topic;
                th.style.border = "2px outset #345db5";

                trh.appendChild(th);

                var tr2 = document.createElement("tr");

                table.appendChild(tr2);

                var td2 = document.createElement("td");

                td2.id = "msg.td";

                tr2.appendChild(td2);

                var content = document.createElement("div");
                content.id = "msg.content";
                content.style.width = "calc(100% - 30px)";
                content.style.height = (height - 105 - 30) + "px";
                content.style.border = "1px inset #eee";
                content.style.overflow = "auto";
                content.style.textAlign = "center";
                content.style.verticalAlign = "middle";
                content.style.padding = "15px";
                content.style.fontSize = "22px";

                content.innerHTML = msg;

                td2.appendChild(content);

                var trf = document.createElement("tr");

                table.appendChild(trf);

                var tdf = document.createElement("td");
                tdf.align = "center";
                tdf.id = "pop_button_panel"

                trf.appendChild(tdf);

                var btn = document.createElement("button");
                btn.id = "ok_button";
                btn.innerHTML = "<span>OK</span>";

                btn.onclick = function () {

                    if (__$("msg.shield")) {

                        if(targeturl){

                              window.location = targeturl

                        }else{

                              document.body.removeChild(__$("msg.shield"));

                        }

                    }

                }

                tdf.appendChild(btn);

            }

            function showConfirmMessage(msg, topic, nextURL,color) {

                  if (!topic) {

                      topic = "Confirm";

                  }

                  var shield = document.createElement("div");
                  shield.style.position = "absolute";
                  shield.style.top = "0px";
                  shield.style.left = "0px";
                  shield.style.width = "100%";
                  shield.style.height = "100%";
                  shield.id = "msg.shield";
                  shield.style.backgroundColor = "rgba(128,128,128,0.5)";
                  shield.style.zIndex = 1050;

                  document.body.appendChild(shield);

                  var width = 420;
                  var height = 280;

                  var div = document.createElement("div");
                  div.id = "msg.popup";
                  div.style.position = "absolute";
                  div.style.width = width + "px";
                  div.style.height = height + "px";
                  div.style.backgroundColor = "#eee";
                  div.style.borderRadius = "1px";
                  div.style.left = "calc(50% - " + (width / 2) + "px)";
                  div.style.top = "calc(50% - " + (height * 0.7) + "px)";
                  div.style.border = "1px outset #fff";
                  div.style.boxShadow = "5px 2px 5px 0px rgba(0,0,0,0.75)";
                  div.style.fontFamily = "arial, helvetica, sans-serif";
                  div.style.MozUserSelect = "none";

                  shield.appendChild(div);

                  var table = document.createElement("table");
                  table.width = "100%";
                  table.cellSpacing = 0;

                  div.appendChild(table);

                  var trh = document.createElement("tr");

                  table.appendChild(trh);

                  var th = document.createElement("th");
                  th.style.padding = "5px";
                  th.style.borderTopRightRadius = "1px";
                  th.style.borderTopLeftRadius = "1px";
                  th.style.fontSize = "20px";
                  if (color){
                      th.style.backgroundColor = color;
                      th.style.border = "2px outset "+color;
                  }else{
                      th.style.backgroundColor = "#79a3c1";
                      th.style.border = "2px outset #79a3c1";
                  }
                  th.style.color = "#fff";
                  th.innerHTML = topic;

                  trh.appendChild(th);

                  var tr2 = document.createElement("tr");

                  table.appendChild(tr2);

                  var td2 = document.createElement("td");

                  tr2.appendChild(td2);

                  var content = document.createElement("div");
                  content.id = "msg.content";
                  content.style.width = "calc(100% - 30px)";
                  content.style.height = (height - 105 - 30) + "px";
                  content.style.border = "1px inset #eee";
                  content.style.overflow = "auto";
                  content.style.textAlign = "center";
                  content.style.verticalAlign = "middle";
                  content.style.padding = "15px";
                  content.style.fontSize = "22px";

                  content.innerHTML = msg;

                  td2.appendChild(content);

                  var trf = document.createElement("tr");

                  table.appendChild(trf);

                  var tdf = document.createElement("td");
                  tdf.align = "center";
                  tdf.id = "pop_button_panel"
                  trf.appendChild(tdf);

                  var btnCancel = document.createElement("button");
                  btnCancel.className = "red";
                  btnCancel.innerHTML = "<span>Cancel</span>";
                  btnCancel.style.minWidth = "100px";

                  btnCancel.onclick = function () {

                      if (__$("msg.shield")) {

                          document.body.removeChild(__$("msg.shield"));

                      }

                  }

                  tdf.appendChild(btnCancel);

                  var btnOK = document.createElement("button");
                  btnOK.id = "ok_button"
                  //btnOK.className = "blue";
                  btnOK.innerHTML = "<span>OK</span>";
                  btnOK.style.minWidth = "100px";

                  if (nextURL)
                      btnOK.setAttribute("nextURL", nextURL);

                      btnOK.onclick = function () {

                          if (__$("msg.shield")) {

                              document.body.removeChild(__$("msg.shield"));

                              if (this.getAttribute("nextURL"))
                                  window.location = this.getAttribute("nextURL");

                      }

                  }

                  tdf.appendChild(btnOK);
}

function ajaxGETRequest(url, callback, optionalControl) {

        if (__$("msg.shield")) {
            document.body.removeChild(__$("msg.shield"));
        }

        var shield = document.createElement("div");
        shield.style.position = "absolute";
        shield.style.position = "absolute";
        shield.style.top = "20%";
        shield.style.left = "20%";
        shield.style.width = "60%";
        shield.style.height = "60%";
        shield.id = "msg.shield";
        shield.style.backgroundColor = "rgba(128,128,128,0.1)";
        shield.style.zIndex = 1050;
        document.body.appendChild(shield);

                                var opts = {
                                      lines: 15             // The number of lines to draw
                                    , length: 56            // The length of each line
                                    , width: 4              // The line thickness
                                    , radius: 40            // The radius of the inner circle
                                    , scale: 1.0            // Scales overall size of the spinner
                                    , corners: 1            // Roundness (0..1)
                                    , color: '#000'         // #rgb or #rrggbb
                                    , opacity: 1/4          // Opacity of the lines
                                    , rotate: 0             // Rotation offset
                                    , direction: 1          // 1: clockwise, -1: counterclockwise
                                    , speed: 1              // Rounds per second
                                    , trail: 100            // Afterglow percentage
                                    , fps: 20               // Frames per second when using setTimeout()
                                    , zIndex: 2e9           // Use a high z-index by default
                                    , className: 'spinner'  // CSS class to assign to the element
                                    , top: '50%'            // center vertically
                                    , left: '50%'           // center horizontally
                                    , shadow: false         // Whether to render a shadow
                                    , hwaccel: false        // Whether to use hardware acceleration (might be buggy)
                                    , position: 'absolute'  // Element positioning
                                  }

                                var spinner = new Spinner(opts).spin(shield)

                                var httpRequest = new XMLHttpRequest();

                                httpRequest.onreadystatechange = function () {

                                    if (httpRequest.readyState == 4 && (httpRequest.status == 200 ||
                                        httpRequest.status == 304)) {

                                        if (httpRequest.responseText.trim().length > 0) {
                                            var result = httpRequest.responseText;

                                            callback(result, optionalControl);

                                            setTimeout(function(){

                                              document.body.removeChild(shield);

                                            },100)

                                        } else {

                                            callback(undefined);

                                        }

                                    }

                                };
                                try {
                                    httpRequest.open("GET", url, true);
                                    httpRequest.send(null);
                                } catch (e) {
                                }

  }
  function  simpleAjaxRequest(url, callback, optionalControl) {

                    var httpRequest = new XMLHttpRequest();

                    httpRequest.onreadystatechange = function () {

                        if (httpRequest.readyState == 4 && (httpRequest.status == 200 ||
                            httpRequest.status == 304)) {

                            if (httpRequest.responseText.trim().length > 0) {
                                var result = httpRequest.responseText;

                                callback(result, optionalControl);

                            } else {

                                callback(undefined);

                            }

                        }

                    };
                    try {
                        httpRequest.open("GET", url, true);
                        httpRequest.send(null);
                    } catch (e) {
                    }

}

function postAjax(url, data, success) {

                  var params = typeof data == 'string' ? data : Object.keys(data).map(

                          function(k){ return encodeURIComponent(k) + '=' + encodeURIComponent(data[k]) }

                      ).join('&');

              
                  var xhr = window.XMLHttpRequest ? new XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");

                  xhr.open('POST', url);

                  xhr.onreadystatechange = function() {

                      if (xhr.readyState>3 && xhr.status==200) { success(xhr.responseText); }

                  };
                  xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');

                  xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

                  xhr.send(params);

                  return xhr;
}

function duplicatesPopup(data,checkbox){
       var people = data.response

       if (__$("msg.shield")) {
            document.body.removeChild(__$("msg.shield"));
        }


        var shield = document.createElement("div");
        shield.style.position = "absolute";
        shield.style.position = "absolute";
        shield.style.top = "0px";
        shield.style.left = "0px";
        shield.style.width = "100%";
        shield.style.height = "100%";
        shield.id = "msg.shield";
        shield.style.backgroundColor = "rgba(128,128,128,0.5)";
        shield.style.zIndex = 1050;
        document.body.appendChild(shield);

        var width = 700;
        var height = 500;

        var div = document.createElement("div");
        div.id = "msg.popup";
        div.style.position = "absolute";
        div.style.width = width + "px";
        div.style.height = height + "px";
        div.style.backgroundColor = "#ffffff";
        div.style.overflowY = "scroll";
        div.style.borderRadius = "1px";
        div.style.left = "calc(50% - " + (width / 2) + "px)";
        div.style.top = "calc(50% - " + (height * 0.6) + "px)";
        div.style.border = "1px outset #fff";
        div.style.boxShadow = "5px 2px 5px 0px rgba(0,0,0,0.75)";
        div.style.fontFamily = "arial, helvetica, sans-serif";
        div.style.MozUserSelect = "none";

        shield.appendChild(div);

        var table = document.createElement("table");
        table.style.marginTop = "0.5%";
        table.style.height = "400px";
        table.style.width = "100%";
        table.style.margin ="auto";
        div.appendChild(table);

        var tr = document.createElement("tr");
        tr.style.height = "30px";
        table.appendChild(tr);

        var th =  document.createElement("th");
        th.colSpan = "5";
        th.style.padding = "0.8em";
        th.style.color = "#ffffff";
        th.style.fontSize = "1.2em";
        th.style.backgroundColor = "#526a83";
        th.innerHTML = "The record is "+(data.exact ? "exact" : "potential")+" duplicate to "+ (people && people.length ? people.length : "0")  +" record(s)";
        tr.appendChild(th);

        var tr = document.createElement("tr");
        tr.style.backgroundColor ="#e0dcdc"
        table.appendChild(tr);

        tr.style.height = "15px";

        var th = document.createElement("th");
        th.innerHTML = "#";
        th.style.padding = "0.5em"
        th.style.float ="left"
        tr.appendChild(th)


        var th = document.createElement("th");
        th.innerHTML = "Name(Sex)";
        tr.appendChild(th);

        var th = document.createElement("th");
        th.innerHTML = "Date of Birth";
        tr.appendChild(th);

        var th = document.createElement("th");
        th.innerHTML = "Mother's name";
        tr.appendChild(th);

        var th = document.createElement("th");
        th.innerHTML = "Father's name";
        tr.appendChild(th);


        if(people){
            for(var i = 0; i < people.length ; i++){
              var tr = document.createElement("tr");
              table.appendChild(tr);
              tr.style.height = "15px";

              var td = document.createElement("td");
              td.style.borderBottom = "1px solid gray";
              td.style.width = "5%";
              td.innerHTML = (i + 1);
              td.style.padding = "0.5em"
              tr.appendChild(td);


              var td = document.createElement("td");
              td.style.textAlign = "center";
              td.style.borderBottom = "1px solid gray";
              td.innerHTML = people[i]["_source"]["first_name"]+" "+ people[i]["_source"]["last_name"] + "("+people[i]["_source"]["gender"].split("")[0]+")";
              tr.appendChild(td);

              var td = document.createElement("td");
              td.style.textAlign = "center";
              td.style.borderBottom = "1px solid gray";
              td.innerHTML = new Date(people[i]["_source"]["birthdate"]).format();
              tr.appendChild(td);

              var td = document.createElement("td");
              td.style.textAlign = "center";
              td.style.borderBottom = "1px solid gray";
              td.innerHTML = (people[i]["_source"]["mother_first_name"] ? people[i]["_source"]["mother_first_name"] : "") +
                             " " +(people[i]["_source"]["mother_last_name"]? people[i]["_source"]["mother_last_name"] : "N/A");
              tr.appendChild(td);

              var td = document.createElement("td");
              td.style.textAlign = "center";
              td.style.borderBottom = "1px solid gray";
               td.innerHTML = (people[i]["_source"]["father_first_name"] ? people[i]["_source"]["father_first_name"] : "") +
                              " "+(people[i]["_source"]["father_last_name"]? people[i]["_source"]["father_last_name"] : "N/A");
              tr.appendChild(td);
            }
        }
        var tr = document.createElement("tr");
        table.appendChild(tr);

        var footdiv = document.createElement("div");
        footdiv.style.width = "100%";
        footdiv.style.height = "25%";
        footdiv.style.textAlign = "center";
        div.appendChild(footdiv);
        if(facility_type  =="facility" && data.exact){
            var ok = document.createElement("button");
            ok.innerHTML = "Cancel";
            ok.className = "red";
            ok.id = "popup.ok"
            ok.style.height = "40px";
            ok.style.width = "15%"
            ok.onclick = function () {
               ids = people.map(function(person){
                    return person["_id"]
               }).join("|");
            
              __$("potential_duplicate").setAttribute("condition",true);
              __$("potential_duplicate").value = ids.toString();

              __$("person_is_exact_duplicate").setAttribute("condition",true)
              __$("person_is_exact_duplicate").value = data.exact
               window.top.location.href = "/people/new_person_type"
            }
            footdiv.appendChild(ok);

        }else{

            var cancel = document.createElement("button");
            cancel.innerHTML = "Cancel";
            cancel.className = "red";
            cancel.id = "popup.cancel"
            cancel.style.height = "40px";
            cancel.style.width = "15%"
            cancel.style.marginRight ="10%";
            cancel.onclick = function () {
               document.body.removeChild(shield);
            }
            footdiv.appendChild(cancel);

            var ok = document.createElement("button");
            ok.innerHTML = "Proceed";
            ok.className = "blue";
            ok.id = "popup.ok"
            ok.style.height = "40px";
            ok.style.width = "15%"
            ok.onclick = function () {
               ids = people.map(function(person){
                    return person["_id"]
               }).join("|");
              __$("potential_duplicate").setAttribute("condition",true);
              __$("potential_duplicate").value = ids.toString();

              __$("person_is_exact_duplicate").setAttribute("condition",true)
              __$("person_is_exact_duplicate").value = data.exact
               if(data.exact && facility_type  =="facility"){
                   window.top.location.href = "/people/new_person_type"
               }else{
                   document.body.removeChild(shield);
                   document.forms[0].submit();            
               }
            }
            footdiv.appendChild(ok);
        }
}

function showModified(title) {

            if (__$("keyboard")) {

                __$("keyboard").style.display = "none";

            }

            if (__$("tt_page_summary")) {

                __$("tt_page_summary").innerHTML = "";

                var table = document.createElement("table");
                table.style.width = "100%";
                table.style.borderCollapse = "collapse";

                __$("tt_page_summary").appendChild(table);

                var tr = document.createElement("tr");

                table.appendChild(tr);

                var th = document.createElement("th");
                th.style.fontSize = "2em";
                th.style.textAlign = "left";
                th.style.padding = "20px";
                th.style.borderBottom = "1px solid #ccc";
                th.innerHTML = title;

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
                tableContent.style.width = "100%";
                tableContent.style.borderCollapse = "collapse";
                tableContent.cellPadding = "10";
                tableContent.style.fontSize = "2em";

                div.appendChild(tableContent);

                var k = 0;

                for (var i = 0; i < tstFormElements.length; i++) {

                    if (tstFormElements[i].value.trim().length <= 0)
                        continue;

                    if (tstFormElements[i].getAttribute("ignore"))
                        continue;

                    if (tstFormElements[i].type == "password")
                        continue;

                    var tr = document.createElement("tr");

                    if (k % 2 > 0)
                        tr.style.backgroundColor = "#eee";

                    tableContent.appendChild(tr);

                    var td = document.createElement("td");
                    td.style.width = "40%";
                    td.style.textAlign = "right";
                    td.style.borderRight = "1px dotted #ccc";
                    td.style.borderBottom = "1px dotted #ccc";
                    td.style.color = "#333";
                    td.style.verticalAlign = "top";
                    td.innerHTML = tstFormElements[i].getAttribute("helpText").beautify("0.9em", "0.55em");

                    tr.appendChild(td);

                    var td = document.createElement("td");
                    td.style.textAlign = "left";
                    td.style.borderBottom = "1px dotted #ccc";
                    td.style.verticalAlign = "top";

                    if (tstFormElements[i].tagName.toLowerCase() == "select") {

                        var opts = tstFormElements[i].selectedOptions;

                        var arr = [];

                        for (var j = 0; j < opts.length; j++) {

                            arr.push(opts[j].innerHTML);

                        }

                        td.innerHTML = arr.join(",");

                    } else {

                        td.innerHTML = tstFormElements[i].value;

                    }

                    tr.appendChild(td);

                    k++;

                }

            }

}