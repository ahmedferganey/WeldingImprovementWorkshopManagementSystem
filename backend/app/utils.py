import pandas as pd
from typing import Dict, Any, List

def import_excel_to_entries(filepath: str, mapping: Dict[str, str]) -> List[Dict[str, Any]]:
    """
    Reads an Excel file and converts rows to WorkshopEntry data
    `mapping` example: {"Sheet Column Name": "field_name"}
    """
    df = pd.read_excel(filepath)
    entries = []
    for _, row in df.iterrows():
        data = {}
        for col, field in mapping.items():
            data[field] = None if pd.isna(row.get(col)) else row.get(col)
        entries.append(data)
    return entries
