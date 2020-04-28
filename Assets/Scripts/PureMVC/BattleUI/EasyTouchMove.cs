using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using TrueSync;
public class EasyTouchMove : MonoBehaviour, IDragHandler,IEndDragHandler{
    //图标移动最大半径
    public float maxRadius = 100;
    //初始化背景图标位置
    private Vector2 moveBackPos;
 
    //hor,ver的属性访问器
    private float horizontal=0;
    private float vertical=0;
    
    public float Horizontal {
        get { return horizontal; }
    }
 
    public float Vertical {
        get { return vertical; }
    }



    //记录左摇杆拖拽的方向（和力度）
    public TSVector2 fMoveDirection;


    public static float touchTime = 0;
  
    // Use this for initialization
    void Start () {
        //初始化背景图标位置
        moveBackPos = transform.parent.transform.position;
	}
	
	// Update is called once per frame
	void Update () {
		horizontal = transform.localPosition.x;
        vertical = transform.localPosition.y;
        float th = Input.GetAxis("Horizontal");
        float tv = Input.GetAxis("Vertical");
        if(Input.GetKey(KeyCode.RightArrow) && th > 0) {
            horizontal += 1;
        }
        if(Input.GetKey(KeyCode.LeftArrow) && th < 0) {
            horizontal += -1;
        }
        if(Input.GetKey(KeyCode.UpArrow) && tv > 0) {
            vertical += 1;
        }
        if(Input.GetKey(KeyCode.DownArrow) && tv < 0) {
            vertical += -1;
        }
        touchTime += Time.deltaTime;
        //Debug.Log("TOUCH    " + horizontal + " , " + vertical);
    }
 
    public void OnDrag(PointerEventData eventData) {
        //获取鼠标位置与初始位置之间的向量
        Vector2 oppsitionVec = eventData.position - moveBackPos;
        //获取向量的长度
        float distance = Vector3.Magnitude(oppsitionVec);
        //最小值与最大值之间取半径
        float radius = Mathf.Clamp(distance, 0, maxRadius);
        //限制半径长度
        transform.position = moveBackPos + oppsitionVec.normalized * radius;


        //用定点数记录摇杆拖拽方向
        var moveDirection = oppsitionVec.normalized*radius;
        fMoveDirection.x = (FP)(((int)(moveDirection.x*1000))*1.0/1000.0);
        fMoveDirection.y = (FP)(((int)(moveDirection.y*1000))*1.0/1000.0);
    }
 
    public void OnEndDrag(PointerEventData eventData) {
        transform.position = moveBackPos;
        transform.localPosition = Vector3.zero;
        fMoveDirection = TSVector2.zero;
    }
}