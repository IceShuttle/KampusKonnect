use super::json::*;
use crate::{
    api::user::auth::utils::*,
    token_json::{GetChatIds, Token, ValidToken},
    SharedState,
};
use axum::{
    extract::{Path, State},
    http::StatusCode,
    Json,
};

pub async fn send_chat(
    State(state): State<SharedState>,
    Path(post_id): Path<i32>,
    Json(payload): Json<SendPostChat>,
) -> Result<StatusCode, StatusCode> {
    let st = state.read().await;
    validate_token(payload.token, &payload.sender, st.jwt_secret_key).await?;
    match sqlx::query!(
        "insert into post_chats(post_id,sender,reciever,message) values($1,$2,$3,$4)",
        post_id,
        payload.sender,
        payload.reciever,
        payload.message
    )
    .execute(&st.pool)
    .await
    {
        Ok(_) => Ok(StatusCode::OK),
        Err(err) => {
            eprintln!("{}", err);
            Err(StatusCode::NOT_FOUND)
        }
    }
}
pub async fn get_chat_ids(
    State(state): State<SharedState>,
    Path(id): Path<i32>,
    Json(payload): Json<GetChatIds>,
) -> Result<Json<Vec<i32>>, StatusCode> {
    let st = state.read().await;
    let claims = decode_token(payload.token.clone(), st.jwt_secret_key).await?;
    validate_token(payload.token, &claims.email, st.jwt_secret_key).await?;
    match sqlx::query!(
        "select chat_id from post_chats where ((sender = $1 and reciever = $2) or (sender = $2 and reciever = $1)) and post_id = $3",
        claims.email,
        payload.communicator,
        id
    )
    .fetch_all(&st.pool)
    .await
    {
        Ok(val) => Ok(Json(val.iter().map(|x| x.chat_id).collect())),
        Err(_) => Err(StatusCode::NOT_FOUND),
    }
}

pub async fn get_chat(
    State(state): State<SharedState>,
    Path(chat_id): Path<i32>,
    Json(payload): Json<Token>,
) -> Result<Json<RecievePostChat>, StatusCode> {
    let st = state.read().await;
    let claims = decode_token(payload.token.clone(), st.jwt_secret_key).await?;
    validate_token(payload.token, &claims.email, st.jwt_secret_key).await?;
    match sqlx::query_as!(RecievePostChat,"select message as chat,sender,reciever,chat_timestamp from post_chats where chat_id = $1 and (sender = $2 or reciever = $2)",
        chat_id,
        claims.email
    ).fetch_one(&st.pool).await{
        Ok(val)=>Ok(Json(val)),
            Err(_)=>Err(StatusCode::NOT_FOUND)
    }
}

pub async fn get_chats(
    State(state): State<SharedState>,
    Json(payload): Json<BulkGet>,
) -> Result<Json<Vec<RecievePostChat>>, StatusCode> {
    let st = state.read().await;
    validate_token(payload.token, &payload.email, st.jwt_secret_key).await?;
    match sqlx::query_as!(RecievePostChat,"select message as chat,sender,reciever,chat_timestamp from post_chats where chat_id = any($1) and (sender = $2 or reciever = $2)",
        &payload.chats,
        payload.email
    ).fetch_all(&st.pool).await{
        Ok(val)=> Ok(Json(val)),
        Err(_)=> Err(StatusCode::INTERNAL_SERVER_ERROR)
    }
}

pub async fn get_chatters(
    State(state): State<SharedState>,
    Path(post_id): Path<i32>,
    Json(payload): Json<ValidToken>,
) -> Result<Json<Vec<String>>, StatusCode> {
    let st = state.read().await;
    validate_token(payload.token, &payload.email, st.jwt_secret_key).await?;
    match sqlx::query!(
        "select distinct sender as chatter from post_chats where post_id = $1 and reciever = $2",
        post_id,
        payload.email
    )
    .fetch_all(&st.pool)
    .await
    {
        Ok(val) => Ok(Json(val.into_iter().map(|x| x.chatter).collect())),
        Err(_) => Err(StatusCode::NOT_FOUND),
    }
}
