create a custom image detection system
# Create directory :
# we have an iternal tool that does this according to the assignemt, if not, might use https://github.com/tzutalin/labelImg
# images//train//dog//dog-train-images
# images//train//cat//cat-train-images
# images//train//squirrel//squirrel-train-images
# images//train//snake//snake-train-images
# images//test//dog//dog-test-images
# images//test//cat//cat-test-images
# images//test//squirrel//squirrel-test-images


from imageai.Detection.Custom import DetectionModelTrainer
model_trainer = ClassificationModelTrainer() #class
model_trainer.setModelTypeAsResNet50() #test multiple models -- some faster, some more accurate, depending on the need, let's assume accuracy is the priority
model_trainer.setDataDirectory("images") #folder with train images from Kenya
model_trainer.trainModel( num_objects=4, num_experiments=500, enhance_data=True, batch_size=32, show_network_summary=True)
# object_names_array:  a list of the names of all the different objects in your dataset.
# num_objects : this is to state the number of object types in the image dataset
# num_experiments : this is to state the number of times the network will train over all the training images, which is also called epochs
# enhance_data (optional) : This is used to state if we want the network to produce modified copies of the training images for better performance.
# batch_size : This is to state the number of images the network will process at ones. The images are processed in batches until they are exhausted per each experiment performed.

## proceeed with the highest performed model
# JSON Mapping for the model classes saved to  C:\Users\User\PycharmProjects\ImageAITest\images\json\model_class.json
## model saved directory

from imageai.Detection.Custom import CustomObjectDetection# import image model
import os # import image library and os class
import uuid
import numpy as np

post_id = uuid.uuid1() # done for post_id

execution_path = os.getcwd() # path to folder with images
detector = CustomObjectDetection() # class
detector.setModelTypeAsResNet50() # model of algorithm
detector.setModelPath(os.path.join(execution_path, "model_class_resnet_ex-056_acc-0.993062.h5")) # prediction goes to this file
detector.setJsonPath(os.path.join(execution_path, "model_class.json")) # see row 26  path to the model_class.json of the model

detector.loadModel(num_objects=6)  # number of models/professions that can be predicted

Post_to_boxes  = detector.detectObjectsFromImage(input_image="images", output_image_path="new_images")

for post_id in Post_to_boxes :
    print( post_id["name"], " : "   ,post_id["box_points"])
