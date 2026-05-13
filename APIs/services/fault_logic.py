def calculate_fault(detected_parts):
    
    report = {
        "detected_parts": detected_parts,
        "accident_type": "Complex / Unclear Impact",
        "car1_fault_percentage": 50,
        "car2_fault_percentage": 50,
        "requires_manual_review": True,
        "description": "Damage pattern requires manual investigation by traffic authorities."
    }

    definitive_front = ["Bonnet", "Windshield"]
    definitive_rear = ["Dickey"]
    ambiguous_parts = ["Bumper", "Light"]
    side_parts = ["Door", "Fender"]

  
    has_front = any(part in detected_parts for part in definitive_front)
    has_rear = any(part in detected_parts for part in definitive_rear)
    has_side = any(part in detected_parts for part in side_parts)
    
   
    has_ambiguous_only = any(part in detected_parts for part in ambiguous_parts) and not (has_front or has_rear or has_side)

    # Scenario 1:
    if has_front and not has_rear:
        report["accident_type"] = "Rear-End Collision"
        report["car1_fault_percentage"] = 100
        report["car2_fault_percentage"] = 0
        report["requires_manual_review"] = False
        report["description"] = "Frontal damage anchor (Bonnet/Windshield) detected. Traffic law assigns 100% fault to the trailing vehicle."

    # Scenario 2:
    elif has_rear and not has_front:
        report["accident_type"] = "Rear-End Collision"
        report["car1_fault_percentage"] = 0
        report["car2_fault_percentage"] = 100
        report["requires_manual_review"] = False
        report["description"] = "Rear damage anchor (Dickey) detected. Vehicle was struck from behind and is assigned 0% fault."

    # Scenario 3: 
    elif has_front and has_rear:
        report["accident_type"] = "Multi-Vehicle Chain Collision"
        report["car1_fault_percentage"] = 100 # Still liable for hitting the car in front
        report["car2_fault_percentage"] = 0
        report["requires_manual_review"] = True
        report["description"] = "Front and rear damage detected indicating a chain-reaction crash. Requires manual review to determine initial impact timing."

    # Scenario 4
    elif has_ambiguous_only:
        report["description"] = "Only ambiguous parts (Bumper/Light) detected. Cannot computationally determine if the impact is frontal or rear without anchor parts. Manual review required."

    return report