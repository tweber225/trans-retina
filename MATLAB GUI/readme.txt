//-----------------------------------------------------------------//
// Name        | readme.txt                  | Type: ( ) source    //
//-------------------------------------------|       ( ) header    //
// Project     | Matlab Imaq Adaptor         |       (*) others    //
//-----------------------------------------------------------------//
// Platform    | PC with several Windows versions                  //
//-----------------------------------------------------------------//
// Environment | Matlab 2015b                                      //
//-----------------------------------------------------------------//
// Purpose     | Instructions for installing the PCO Camera Adaptor//
//             | for matlab image acquisition toolbox              //
//-----------------------------------------------------------------//
// Author      | DKI, PCO AG                                       //
//-----------------------------------------------------------------//
// Revision    | 0,0,00,02                                         //
//-----------------------------------------------------------------//
// Notes       |                                                   //
//             |                                                   //
//             |                                                   //
//             |                                                   //
//-----------------------------------------------------------------//
// (c) 2014-2015 PCO AG * Donaupark 11 *                           //
// D-93309      Kelheim / Germany * Phone: +49 (0)9441 / 2005-0 *  //
// Fax: +49 (0)9441 / 2005-20 * Email: info@pco.de                 //
//-----------------------------------------------------------------//


To use the adaptor for the image acquisition toolbox in matlab, follow these steps:

1.	Open matlab and make sure you have the image acquisition toolbox installed 
	(by typing ver in the matlab command window)

2.	Choose the folder where this readme file is located as current folder of matlab

3.	Register the adaptor in the toolbox by calling pco_imaqregister or pco_imaqregister('register') in the matlab command line
	This will copy the suitable PCOCameraAdaptor.dll and the required interface dlls 
	from the appropriate plattform and version subfolder to the current folder and the adaptor will be registered

(Note: By calling pco_imaqregister('unregister') you can unregister the PCOCameraAdaptor)

To check if the register was successful, type imaqhwinfo in the command window. 
Here pcocameraadaptor has to appear in the line of InstalledAdaptors
	
After completing these steps you will be able to access the pco cameras from the image acquisition toolbox.