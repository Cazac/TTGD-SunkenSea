using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SS_Player : MonoBehaviour
{

    public CharacterController player_CC;



    [Header("Player Speeds")]
    //private float defaultSpeed = 16f;
    //private float sprintSpeed = 20f;


    private Vector3 moveLeft_V3 = new Vector3(-4, 0, 0);
    private Vector3 moveRight_V3 = new Vector3(4, 0, 0);
    private Vector3 moveJump_V3 = new Vector3(0, 50, 0);


    private Vector3 ladderUp_V3 = new Vector3(0, 10, 0);
    private Vector3 ladderDown_V3 = new Vector3(0, -10, 0);


    private float fallingSpeed;
    private readonly float gravityAcceleration = -20f;
    private readonly float gravityTerminalVelocity = -40f;
    private readonly float jumpVelocity = 8f;



    private GameObject connectItem_Ladder;

    public bool isConnectedToLadder;
    public bool isLeavingLadder;
    public bool isCappedLadder;

    ///////////////////////////////////////////////////////

    public void TakePlayerInput()
    {
        if (isConnectedToLadder)
        {
            if (Input.GetKey(KeyCode.Space) || Input.GetKey(KeyCode.A) || Input.GetKey(KeyCode.D))
            {
                //Break Connection
                DisconnectFromLadder();

                //Replay With Free Movement
                TakePlayerInput();
            }
            else
            {
                //Create A New Movement Vector that will be applied
                Vector3 currentMovement = new Vector3(0, 0, 0);

                currentMovement = PlayerMove_Ladder(currentMovement);

                //Move the player
                player_CC.Move(currentMovement * Time.deltaTime);

                //Snap Connection To X Axis Ladder
                gameObject.transform.position = new Vector3(connectItem_Ladder.transform.position.x, gameObject.transform.position.y, gameObject.transform.position.z);
            }
        }
        else
        {
            //Create A New Movement Vector that will be applied
            Vector3 currentMovement = new Vector3(0, 0, 0);

            currentMovement = PlayerMove_Left(currentMovement);
            currentMovement = PlayerMove_Right(currentMovement);
            currentMovement = PlayerMove_Vertical(currentMovement);

            //Move the player
            player_CC.Move(currentMovement * Time.deltaTime);

            isLeavingLadder = false;
        }
    }

    public void TakeAIInput()
    {
        //Create A New Movement Vector that will be applied
        Vector3 currentMovement = new Vector3(0, 0, 0);

        currentMovement = AIMove_Vertical(currentMovement);

        //Move the player
        player_CC.Move(currentMovement * Time.deltaTime);      
    }

    ///////////////////////////////////////////////////////

    public Vector3 PlayerMove_Right(Vector3 currentMovement)
    {
        if (Input.GetKey(KeyCode.A))
        {
            currentMovement += moveLeft_V3;
        }

        return currentMovement;
    }

    public Vector3 PlayerMove_Left(Vector3 currentMovement)
    {
        if (Input.GetKey(KeyCode.D))
        {
            currentMovement += moveRight_V3;
        }

        return currentMovement;
    }

    public Vector3 PlayerMove_Vertical(Vector3 currentMovement)
    {
        //No Touching Go down
        if (player_CC.isGrounded || isLeavingLadder)
        {            
            //Reset Falling Speed
            fallingSpeed = 0;
        }
        else
        {
            //Fall Speed
            fallingSpeed += gravityAcceleration * Time.deltaTime;

            //Cap Falling Speed at terminal Velocity
            if (fallingSpeed < gravityTerminalVelocity)
            {
                fallingSpeed = gravityTerminalVelocity;
            }

            //Set Fall Velocity
            Vector3 moveFallingSpeed_V3 = new Vector3(0, fallingSpeed, 0);
            currentMovement += moveFallingSpeed_V3;
        }




        //Jumping
        if (Input.GetKey(KeyCode.Space) && (player_CC.isGrounded || isLeavingLadder))
        {
            fallingSpeed = jumpVelocity;

            Vector3 moveFallingSpeed_V3 = new Vector3(0, fallingSpeed, 0);
            currentMovement += moveFallingSpeed_V3;
        }


     





        return currentMovement;
    }

    public Vector3 PlayerMove_Ladder(Vector3 currentMovement)
    {
        if (Input.GetKey(KeyCode.W))
        {
            currentMovement += ladderUp_V3;

            if (isCappedLadder)
            {
                // float height = GetComponent<MeshFilter>().mesh.bounds.extents.y;

                Debug.Log("Capped");

                currentMovement = new Vector3(0, 0, 0);

                //Snap Connection To X Axis Ladder
                //gameObject.transform.position = new Vector3(gameObject.transform.position.x, connectItem_Ladder.transform.position.y + height, gameObject.transform.position.z);
            }
        }

        if (Input.GetKey(KeyCode.S))
        {
            currentMovement += ladderDown_V3;

            if (isCappedLadder)
            {
                // float height = GetComponent<MeshFilter>().mesh.bounds.extents.y;

                //Debug.Log("Capped");

                //currentMovement = new Vector3(0, 0, 0);

                //Snap Connection To X Axis Ladder
                //gameObject.transform.position = new Vector3(gameObject.transform.position.x, connectItem_Ladder.transform.position.y + height, gameObject.transform.position.z);
            }
        }



       


        return currentMovement;
    }

    ///////////////////////////////////////////////////////

    public Vector3 AIMove_Vertical(Vector3 currentMovement)
    {
        //No Touching Go down
        if (!player_CC.isGrounded)
        {
            //Fall Speed
            fallingSpeed += gravityAcceleration * Time.deltaTime;

            //Cap Falling Speed at terminal Velocity
            if (fallingSpeed < gravityTerminalVelocity)
            {
                fallingSpeed = gravityTerminalVelocity;
            }

            //Set Fall Velocity
            Vector3 moveFallingSpeed_V3 = new Vector3(0, fallingSpeed, 0);
            currentMovement += moveFallingSpeed_V3;
        }
        else
        {
            //Reset Falling Speed
            fallingSpeed = 0;
        }




        //Jumping
        if (Input.GetKey(KeyCode.Space) && player_CC.isGrounded)
        {
            //fallingSpeed = jumpVelocity;



            //Vector3 moveFallingSpeed_V3 = new Vector3(0, fallingSpeed, 0);
            //currentMovement += moveFallingSpeed_V3;

            //currentMovement += moveJump_V3;
        }








        return currentMovement;
    }

    ///////////////////////////////////////////////////////

    public void ConnectToLadder(GameObject ladder)
    {
        connectItem_Ladder = ladder;

        isConnectedToLadder = true;
        isCappedLadder = false;
        isLeavingLadder = false;
    }

    public void DisconnectFromLadder()
    {
        connectItem_Ladder = null;

        isConnectedToLadder = false;
        isCappedLadder = false;
        isLeavingLadder = true;
    }

    public void CappedLadder()
    {

        isCappedLadder = true;

    }

    ///////////////////////////////////////////////////////
}