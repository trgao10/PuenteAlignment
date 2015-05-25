$!/bin/bash


case $1 in
    alan) python alan.py
        ;;
    baker) python baker.py
        ;;
    cqo1_fusion) python cqo1_fusion.py
        ;;
    diet) python diet.py
        ;;
    facility_location) python facility_location.py
        ;;
    lo1_fusion) python lo1_fusion.py
        ;;
    lownerjohn_ellipsoid) python lownerjohn_ellipsoid.py
        ;;
    markowitz1) python markowitz1.py
        ;;
    milo1_fusion) python milo1_fusion.py
        ;;
    portfolio) python portfolio.py ../data/portex
        ;;
    sdo1) python sdo1.py
        ;;
    simple) python simple.py
        ;;
    sospoly) python sospoly.py
        ;;
    TrafficNetworkModel) python TrafficNetworkModel.py
        ;;

    all)
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
        python simple.py
        python TrafficNetworkModel.py
        ;;
    *)
        echo "Usage: run.sh NAME"
esac


