White matter maturation processes implementation in FaBiAN simulator
===========================================================================
----

__Copyright (c) 2019-2023__  

__Medical Image Analysis Laboratory (MIAL), Lausanne, Switzerland__  
__Department of Radiology, Lausanne University Hospital (CHUV) and University of Lausanne (UNIL), Lausanne, Switzerland__  
__CIBM Center for Biomedical Imaging, Switzerland__

----

The code from this folder is adapted to work on the public Gholipour's normative spatiotemporal fetal brain [atlas](http://crl.med.harvard.edu/research/fetal_brain_atlas/).

>Below is described how the white matter implementation should be done:
>
> - First apply the the *White Matter improvement/fsl_clustering.py* script on the desired dataset. Each high resolution brain volume should be in a different folder along with its segmentation map. If you are going to  apply this script to a different dataset, make sure you have changed the white matter labels to recover a good cropping of the white matter volume.
> - Now that FAST has been applied, in each folder you will have available the high resolution brain volume, the segmentation map, the white matter volume and the outputs from FAST tool. But we are only interested in the partial volume maps which will be take as inputs for the FaBiAN simulator in *Utilities/WM_maturation.m* file.
> - If adaptive clipping values is desired for the current dataset, apply the *White_Matter_improvement/clipping_value_building.py* to (ONLY) the the white matter volumes of each subject. The result can be then pasted in *Utilities/clip_function.m*
>
Note: Make sure that the partial volume map paths are correct in *Utilities/WM_maturation.m*

## Contact
For any questions, please contact: 
Andrés le Boeuf
andres.le.boeuf@estudiantat.upc.edu

OR

Hélène Lajous  
helene.lajous@unil.ch 
