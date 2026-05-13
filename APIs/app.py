from flask import Flask, request, jsonify
from ultralytics import YOLO
from PIL import Image, ImageOps
import io

# Import your custom logic from the services folder!
from services.fault_logic import calculate_fault
from services.plate_logic import decode_plate

app = Flask(__name__)


model = YOLO("models/CDD_Enahanced.pt")
plate_model = YOLO("models/plate_model.pt")

@app.route("/extract-plate", methods=['POST'])
def extract_plate():
    if 'image' not in request.files:
        return jsonify({"error": "No image provided"}), 400
    
    file = request.files['image']
    
    # 1. Load the image into PIL
    image = Image.open(file.stream)
    image = ImageOps.exif_transpose(image)
    image = image.convert("RGB")
    result = plate_model(image) 

    num_boxes = len(result[0].boxes)


    if num_boxes > 0:
        plate_text = decode_plate(result[0].boxes, plate_model.names)
        confidence = min(99, num_boxes * 14)
        
        return jsonify({
            "status": "success",
            "license_plate": plate_text,
            "confidence": confidence
        })
    else:
        return jsonify({
            "status": "success",
            "license_plate": None,
            "confidence": 0
        })

@app.route('/analyze-accident', methods=['POST'])
def analyze_accident():
    if 'image' not in request.files:
        return jsonify({"error": "No image provided"}), 400

    file = request.files['image']
    image = Image.open(file.stream)
    image = ImageOps.exif_transpose(image)
    image = image.convert("RGB")

    results = model(image)
    detected_parts = []
    for r in results:
        for box in r.boxes:
            class_id = int(box.cls[0])
            class_name = model.names[class_id]
            detected_parts.append(class_name)

    detected_parts = list(set(detected_parts))

    # Pass the labels to your services file
    final_report = calculate_fault(detected_parts)

    return jsonify(final_report)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)