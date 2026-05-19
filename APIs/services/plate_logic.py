def decode_plate(boxes, class_names):
    """
    Takes YOLO bounding boxes, enforces Saudi plate format (max 3 letters, 
    max 4 digits), selects by highest confidence, sorts left-to-right,
    and returns the final license plate string.
    """
    letters = []
    digits = []

    for box in boxes:
        conf = float(box.conf[0])
        x_min = float(box.xyxy[0][0])
        class_id = int(box.cls[0])
        char = class_names[class_id]

        if char.isalpha():
            letters.append((conf, x_min, char))
        else:
            digits.append((conf, x_min, char))

    # Keep only the top N by confidence, then sort spatially left-to-right
    top_letters = sorted(
        sorted(letters, key=lambda item: item[0], reverse=True)[:3],  # top 3 conf
        key=lambda item: item[1]  # sort by x_min
    )
    top_digits = sorted(
        sorted(digits, key=lambda item: item[0], reverse=True)[:4],   # top 4 conf
        key=lambda item: item[1]
    )

    if not top_letters and not top_digits:
        return None

    # Saudi plates: digits on the left, letters on the right
    plate_string = (
        "".join(item[2] for item in top_digits) +
        " " +
        "".join(item[2] for item in top_letters)
    )

    return plate_string.strip()