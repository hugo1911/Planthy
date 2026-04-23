#El código fue sacado de documentación de apple (Coremltools)
#y de stackoverflow vaya que se creen superiores unos que otros:p


import onnx
import coremltools as ct

onnx_model = onnx.load("best_model_customcnn.onnx")

#Checamos inputs y outputs para que todo esté en orden
print("aqui van los inputs de onnx")
for inp in onnx_model.graph.input:
    shape = [d.dim_value for d in inp.type.tensor_type.shape.dim]
    print(f"  name='{inp.name}'  shape={shape}")

#Esperamos que nos de algo como [1, 3] ya que es una imagen pero pues son 3 posibilidades en nuestro caso
print("outputs de onnx")
for out in onnx_model.graph.output:
    shape = [d.dim_value for d in out.type.tensor_type.shape.dim]
    print(f"  name='{out.name}'  shape={shape}")

mlmodel = ct.convert(
    "best_model_customcnn.onnx",
    source="pytorch",
    minimum_deployment_target=ct.target.iOS17, #Solo es la version de iOS
)

#Solo metadatos basicos que cuando abres el modelo en xcode te da esta info
mlmodel.author = "Planthy"
mlmodel.short_description = "Plant disease classifier: healthy / rust / powdery_mildew"
mlmodel.save("Planthy/Planthy/Planthy/Resources/PlantModel.mlmodel") #Ruta para guardar el modelo 
print("\nSaved PlantModel.mlmodel")

spec = mlmodel.get_spec()
print("\nAqui estan los inputs de coreml") 
for inp in spec.description.input:
    print(f"  '{inp.name}'")
print("Outputs de coreml")
for out in spec.description.output:
    print(f"  '{out.name}'")
