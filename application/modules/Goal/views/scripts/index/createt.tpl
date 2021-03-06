<?php 
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    goals
 * @copyright  Copyright 2014 Stars Developer
 * @license    http://www.starsdeveloper.com 
 * @author     Stars Developer
 */
?>
<?php echo $this->content()->renderWidget('goal.browse-menu') ?>
<?php 
if($this->notemplates){
?>
<div class="tip">
    <span>
    <?php echo $this->translate('Sorry no templates exists');?>
    </span>
</div> 

<?php
return;
}
?>
<?php echo $this->form->render() ?>

<script type="text/javascript">
  var cal_starttime_onHideStart = function(){
    // check end date and make it the same date if it's too
    cal_endtime.calendars[0].start = new Date( $('starttime-date').value );
    // redraw calendar
    cal_endtime.navigate(cal_endtime.calendars[0], 'm', 1);
    cal_endtime.navigate(cal_endtime.calendars[0], 'm', -1);
  }
  var cal_endtime_onHideStart = function(){
    // check start date and make it the same date if it's too
    cal_starttime.calendars[0].end = new Date( $('endtime-date').value );
    // redraw calendar
    cal_starttime.navigate(cal_starttime.calendars[0], 'm', 1);
    cal_starttime.navigate(cal_starttime.calendars[0], 'm', -1);
  }
</script>

<script type="text/javascript">
  $$('.core_main_goal').getParent().addClass('active');
</script>

<script type="text/javascript">
window.addEvent("domready",function(){
$$("#task-wrapper").setStyle("display","none");
});
document.getElementById("template_id").onchange = function() {
    var template_id = document.getElementById("template_id").value;
 
     var request = new Request.HTML({
      'url' : en4.core.baseUrl + 'goals/temptasks',
      'data' : {
        'format' : 'html',
        'template_id' : template_id
        
      },
      'onComplete' : function(tasks) {
       
          var div = $$(tasks);
          
           var task = div[0].getElements("#task-element .form-options-wrapper li");         
           if(task.length != 0){
             $$("#task-wrapper").setStyle("display","block");
            var taskElement = $$("#task-element .form-options-wrapper");
            taskElement.set("html","");
            task.inject(taskElement[0]);  
            }else {
             $$("#task-wrapper").setStyle("display","none");
            }
         
         
           var description = div[0].getElement("#temp_description");
            if(description != null){
                    tinyMCE.activeEditor.setContent(description.get("html"));
             }     
        
          var photo = div[0].getElement(".temp_photo");        
          if(photo != null){
                    //if already photo is set to temp_photo
                    
                    var temp_photo = $$(".temp_photo");
                    if(temp_photo){
                       temp_photo.setStyle("display","none");
                        }
                    
                   var photoElement = $$("#photo-element");
                    //photoElement.set("html","");
                    photo.inject(photoElement[0],"top");
                }else {
                 var temp_photo = $$(".temp_photo");
                    if(temp_photo){
                       temp_photo.setStyle("display","none");
                        }
                }
          
                 
           
      }
    });
    request.send();
 
};
</script>
    
