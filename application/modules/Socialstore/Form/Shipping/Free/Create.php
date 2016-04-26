<?php

class Socialstore_Form_Shipping_Free_Create extends Engine_Form{
	public function init(){
		//Set Form Informations
	    $this -> setAttribs(array('class' => 'global_form','method' => 'post'))
	          -> setTitle('Add New Shipping Method');
		
        $this->addElement('Hidden','shippingmethod_id');  
		
		$this->addElement('Hidden','shippingrule_id');  
	    
		$this->addElement('Radio','all_cats',array(
			'label'=>'Applied to All Categories',
			'required'=>true,
			'onchange' => 'en4.store.shippingCategories($(this))',
			'multiOptions' => array(
				'0' => 'No',
				'1' => 'Yes'
			),
			'value' => 0,
		));
		$this->all_cats->getDecorator("Description")->setOption("placement", "append");
		$store_id = Zend_Registry::get('store_id');
		$sql = "Select customcategory_id,name FROM engine4_socialstore_customcategories where store_id = '$store_id'";
		$db = Engine_Db_Table::getDefaultAdapter();
		$categories = $db -> fetchPairs($sql);
		$this->addElement('Multiselect','category',array(
			'label'=>'Categories',
			'required'=>false,
			'multiOptions' => $categories,
		));
		
		$this->addElement('Radio','all_countries',array(
			'label'=>'Applied to All Countries',
			'required'=>true,
			'onchange' => 'en4.store.shippingCountries($(this))',
			'multiOptions' => array(
				'0' => 'No',
				'1' => 'Yes'
			),
			'value' => 0,
		));
		$this->all_countries->getDecorator("Description")->setOption("placement", "append");
		$sql = "Select code,country FROM engine4_socialstore_countries";
		$db = Engine_Db_Table::getDefaultAdapter();
		$countries = $db -> fetchPairs($sql);
		$this->addElement('Multiselect','country',array(
			'label'=>'Countries',
			'required'=>false,
			'multiOptions' => $countries,
		));
		
		$this->addElement('Text', 'order_minimum',array(
	      	'label'=>'Minimum Purchase Amount*',
	      	'title' => '',  
	      	'allowEmpty' => false,
	      	'required'=>true,
	      	'description' => 'Minimum Purchase Amount',
	      	'filters' => array(
	        	new Engine_Filter_Censor(),
	      	),
	     	'value'=>    '0.00',
	      	'validators' => array(
	        	array('NotEmpty', true),
	       		array('Float', true),
	       		array('GreaterThan',true,array(0))
    	)));
    	$this->order_minimum->getDecorator("Description")->setOption("placement", "append");
		
		$this->addElement('Button', 'execute', array(
	      'label' => 'Save',
	      'type' => 'submit',
	      'ignore' => true,
	      'decorators' => array(
	        'ViewHelper',
	      ),
	    ));
		
	    
	    // Element: cancel
	    $this->addElement('Cancel', 'cancel', array(
	      'label' => 'cancel',
	      'link' => true,
	      'prependText' => ' or ',
	      'onclick' => 'javascript:parent.Smoothbox.close()',
	      'decorators' => array(
	        'ViewHelper',
	      ),
	      
	    ));
     // DisplayGroup: buttons
    $this->addDisplayGroup(array(
      'execute',
    	'cancel',
      ), 'buttons', array(
      'decorators' => array(
        'FormElements',
        'DivDivDivWrapper'
      ),
    ));
	}
}