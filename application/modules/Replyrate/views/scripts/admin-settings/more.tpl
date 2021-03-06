<h2>
  <?php echo $this->translate("Reply Rate") ?>
</h2>
<p>
  <?php echo $this->translate("Reply rate shows the ratio of incoming messages and answers to them. If the Reply rate is
low then user answers rarely, if the Reply rate is high then the probability of response is much
higher. <br />Use the <a href=admin/content>layuot editor</a> to arrange the Reply Rate you want on each page.") ?>
</p>
<br />
<?php if( count($this->navigation) ): ?>
  <div class='tabs'>
    <?php
      // Render the menu
      //->setUlClass()
      echo $this->navigation()->menu()->setContainer($this->navigation)->render()
    ?>
  </div>
<?php endif; ?>

<?php echo $this->content()->renderWidget('replyrate.more-plugins') ?>
