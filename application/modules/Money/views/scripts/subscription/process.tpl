<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
?>
<script type="text/javascript">
  window.addEvent('load', function(){
    var url = '<?php echo $this->transactionUrl ?>';
    var data = <?php echo Zend_Json::encode($this->transactionData) ?>;
    var request = new Request.Post({
      url : url,
      data : data
    });
    request.send();
  });
</script>
