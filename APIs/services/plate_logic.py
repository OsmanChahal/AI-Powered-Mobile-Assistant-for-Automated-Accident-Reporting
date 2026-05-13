def decode_plate(boxes, class_names):
    """
    Takes YOLO bounding boxes, sorts them geometrically from left to right,
    and returns the final license plate string.
    """
    characters = []
    
    for box in boxes:
        # Extract the X-coordinate of the left side of the bounding box
        x_min = float(box.xyxy[0][0])
        class_id = int(box.cls[0])
        char = class_names[class_id]
        
        characters.append((x_min, char))
    
    # Sort the list based on the X-coordinate (Left to Right)
    characters.sort(key=lambda item: item[0])
    
    # If no characters were detected, return None so Flask sends null in JSON
    if not characters:
        return None

    # Join the characters into a single string
    plate_string = "".join([item[1] for item in characters])
    
    return plate_string