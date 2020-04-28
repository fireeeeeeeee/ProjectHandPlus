using UnityEngine;
using TrueSync;

public class test : MonoBehaviour
{
    public FP fp;
    // Start is called before the first frame update
    public int myInt;
    public float myFloat;
    public double myDouble;
    public decimal myDecimal;
    public long myLong;

    public long myFpser;

    public long tt;

    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        fp = FP.One * tt;
        myFpser = fp._serializedValue;
        myInt = fp.AsInt();
        myFloat = fp.AsFloat();
        myDouble = fp.AsDouble();
        myDecimal = fp.AsDecimal();
        myLong = fp.AsLong();
    }
}
