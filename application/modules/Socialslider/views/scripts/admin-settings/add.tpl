
<?php $this->headScript()
        ->appendFile($this->layout()->staticBaseUrl . 'application/modules/Socialslider/externals/scripts/jscolor/jscolor.js') ?>

<h2>
    <?php echo $this->translate('Social Slider plugin'); ?>
</h2>

<?php if(count($this->navigation)):?>
    <div class="tabs">
        <?php echo $this->navigation()->menu()->setContainer($this->navigation)->render(); ?>
    </div>
<?php endif;?>
<div class="settings">
    <?php echo $this->form->render(); ?>
</div>