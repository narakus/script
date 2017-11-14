var mytd = document.getElementsByTagName('td');
for(var i=0;i<=mytd.length -1;i++){
var item = mytd[i];
if(item.getAttribute('id') == 'status'){
var p = item.parentElement;
if(item.innerHTML == 0){
p.setAttribute("class","active");
}
else if(item.innerHTML == 1){
p.setAttribute("class","warning");
}

else if(item.innerHTML == 2){
p.setAttribute("class","danger");

}
}
}

var i = {{ taskid }}
console.log(i)

function DoAjax(){
                var l1 = document.getElementsByName('c1');
                var arr = new Array();
                var alldate = {};
                for (var i = 0;i <= l1.length - 1; i++) {
                        var s = l1[i];
                        if(s.checked){
                                var svnpath = s.parentElement.parentElement.cells[1].innerHTML;
                                var filename = s.parentElement.parentElement.cells[2].innerHTML;
                                var ip = s.parentElement.parentElement.cells[3].innerHTML;
                                var uploader = s.parentElement.parentElement.cells[4].innerHTML;
                                var size = s.parentElement.parentElement.cells[5].innerHTML;
                                var uploadtime = s.parentElement.parentElement.cells[6].innerHTML;
                                var version = s.parentElement.parentElement.cells[7].innerHTML;
                                var serverpath = s.parentElement.parentElement.cells[8].innerHTML;
                                var stat = s.parentElement.parentElement.cells[9].innerHTML;
                                var k = ip + '___' + filename
                                var m = {"filename":filename,"ip":ip,"serverpath":serverpath,"svnpath":svnpath,"uploader":uploader,"size":size,"uploadtime":uploadtime,"version":version,"stat":stat};

                               alldate[k] = m;
                               console.log(alldate)
                        }
   ;}

               $.ajax({
                       url:'/server/',
                       type:'POST',
                       data:alldate,
                       success:function(callback){
                           console.log(callback);
                       },
                       error:function(){
                           console.log('failed');
                       }
               })
        }
