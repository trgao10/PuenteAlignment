if %1 EQU alan. ( 
    python alan.py
) else if %1 EQU baker. (
    python baker.py
) else if %1 EQU cqo1_fusion. (
    python cqo1_fusion.py
) else if %1 EQU diet. (
    python diet.py
) else if %1 EQU facility_location. (
    python facility_location.py
) else if %1 EQU lo1_fusion. (
    python lo1_fusion.py
) else if %1 EQU lownerjohn_ellipsoid. (
    python lownerjohn_ellipsoid.py
) else if %1 EQU markowitz1. (
    python markowitz1.py
) else if %1 EQU milo1_fusion. (
    python milo1_fusion.py
) else if %1 EQU portfolio. (
    python portfolio.py ../data/portex
) else if %1 EQU sdo1. (
    python sdo1.py
) else if %1 EQU sospoly. (
   python sospoly.py       
) else if %1 EQU simple. (
    python simple.py
) else if %1 EQU TrafficNetworkModel. (
    python TrafficNetworkModel.py
) else if %1 EQU all. (
    python alan.py
    python baker.py
    python cqo1_fusion.py
    python diet.py
    python facility_location.py
    python lo1_fusion.py
    python lownerjohn_ellipsoid.py
    python markowitz1.py
    python milo1_fusion.py
    python portfolio.py ../data/portex
    python sdo1.py
    python sospoly.py
    python simple.py
    python TrafficNetworkModel.py
) else (
    echo "Usage: run.bat NAME"
)


