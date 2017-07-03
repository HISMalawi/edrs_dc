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

function duplicatesPopup(people,checkbox){
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
        table.style.border = "1px solid gray";
        table.style.height = "425px";
        table.style.width = "98%";
        table.style.margin ="auto";
        div.appendChild(table);

        var tr = document.createElement("tr");
        tr.style.height = "30px";
        table.appendChild(tr);
        var th =  document.createElement("th");
        th.colSpan = "3";
        th.style.padding = "0.8em";
        th.style.color = "#ffffff";
        th.style.fontSize = "1.2em";
        th.style.backgroundColor = "#526a83";
        th.innerHTML = "The record is potential duplicate to "+ (people && people.length ? people.length : "0")  +" records";
        tr.appendChild(th);
        if(people){
            for(var i = 0; i < people.length ; i++){
              var tr = document.createElement("tr");
              table.appendChild(tr);
              tr.style.height = "25px";
              var td = document.createElement("td");
              td.style.borderBottom = "1px dotted gray";
              td.style.width = "5%";
              td.style.padding = "0.5em";
              td.innerHTML = (i + 1);

              tr.appendChild(td);
              var td = document.createElement("td");
              td.style.padding = "0.5em";
              td.style.borderBottom = "1px dotted gray";
              td.innerHTML =people[i][1];
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

        /*var duplicate = document.createElement("button");
        duplicate.innerHTML = "Duplicate";
        footdiv.appendChild(duplicate);

        var notduplicate = document.createElement("button");
        notduplicate.innerHTML = "Not duplicate";
        footdiv.appendChild(notduplicate);*/

        var ok = document.createElement("button");
        ok.innerHTML = "OK";
        ok.id = "popup.ok"
        ok.onclick = function () {
           document.body.removeChild(shield);
        }
        footdiv.appendChild(ok);




}
