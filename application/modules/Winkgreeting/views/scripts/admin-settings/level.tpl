<h2>
  <?php echo $this->translate("Wink and Greeting") ?>
</h2>
<p>
<?php echo $this->translate("Plugin provides two useful options (wink and greeting) which help in establishing contact between users. When you click on one of these options the profile owner gets a message what you like his profile and your are interested in communicating with him.") ?>
</p>
<br />
<script type="text/javascript">
  var fetchLevelSettings =function(level_id){
    window.location.href= en4.core.baseUrl+'admin/winkgreeting/settings/level/'+level_id;
    //alert(level_id);
  }
</script>

<?php if( count($this->navigation) ): ?>
  <div class='tabs'>
    <?php
      // Render the menu
      //->setUlClass()
      echo $this->navigation()->menu()->setContainer($this->navigation)->render()
    ?>
  </div>
<?php endif; ?>

<div class='settings'>
  <?php echo $this->form->render($this) ?>
</div>