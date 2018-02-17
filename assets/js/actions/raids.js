import 'whatwg-fetch';
import * as types from './actionTypes';
import configureChannel from '../utils/channel';
import logger from '../utils/logger';


const socket = configureChannel();
const channel = socket.channel('raids');


export function isFetching(bool) {
  return {
    type: types.FETCHING_RAIDS,
    isFetching: bool,
  };
}


export function raidsFetchSuccess(items) {
  return {
    type: types.RAID_FETCH_SUCCESS,
    items,
  };
}

export function syncChannelSuccess(payload) {
  return {
    type: types.SYNC_CHANNEL_SUCCESS,
    channel: payload.channel_slug,
    raids: payload.raids,
  };
}

export function fetchRaids() {
  return (dispatch) => {
    dispatch(isFetching(true));
    channel.join()
      .receive('ok', (messages) => {
        logger.debug('catching up', messages);
        dispatch(raidsFetchSuccess(messages.raids));
      })
      .receive('error', (reason) => {
        logger.debug('failed join', reason);
        dispatch(raidsFetchSuccess(reason));
      });

    channel.on('sync_channel', (msg) => {
      logger.debug('sync_channel', msg);
      dispatch(syncChannelSuccess(msg));
    });
  };
}
