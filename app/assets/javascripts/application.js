// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery3
//= require popper
//= require bootstrap
  
//= require rails-ujs
//= require activestorage
//= require direct_uploads
//= require turbolinks
//= require cable
//= require jquery.infinitescroll
  
//= require_self

$(document).on('turbolinks:load', function() {
  
  // Open post thread modal
  $('[data-action="openThread"]').on('click', function (event) {
    if (!$(event.target).is('a') && !$(event.target).parents('a').length) {
      var modal = $('#threadModal');
      modal.modal('show');

      var dataContainer = document.querySelector($(this).data('json'));
      if (dataContainer == null) {
        return;
      }
      var data = JSON.parse(dataContainer.innerText);

      var template = modal.find('#thread-post-template').html();
      var container = modal.find('.original-posts');
      container.html('');

      var selectedPost;

      data.forEach(function(post) {
        var postDiv = $(template);
        if (post.profilePicture) {
          postDiv.find('.profile-picture').attr("src", post.profilePicture).show();
        }
        else {
          postDiv.find('.profile-picture').hide();
        }
        postDiv.find('.display-name').text(post.displayName);
        postDiv.find('.username').text('@' + post.username);
        postDiv.find('.created-at').text(post.createdAt);
        postDiv.find('.content').text(post.content);
        postDiv.find('.attachments').text('');
        post.attachments.forEach(function(attachment) {
          postDiv.find('.attachments').append(`<a href="${attachment.url}" target="_blank"><img src="${attachment.preview_url}"></a>`);
        });
        container.append(postDiv);
        if (post.current) {
          selectedPost = post;
          postDiv.addClass('selected');
        }
      });

      if (typeof selectedPost != "undefined") {
        modal.find('.username').text('@' + selectedPost.username);
        modal.find('input[name="original_post_id"]').val(selectedPost.id);
        modal.find('input[name="original_user_id"]').val(selectedPost.userId);
      }
    }
  });
  $('#threadModal').on('shown.bs.modal', function (event) {
    var selectedDiv = $(this).find('.post.selected');
    if (typeof selectedDiv != "undefined") {
      $('#threadModal').animate({scrollTop: selectedDiv.offset().top - 50}, 'fast');
    }
  });
  
  // Open reply modal
  $('[data-action="reply"]').on('click', function (event) {
    var modal = $('#replyModal');
    modal.modal('show');
    
    var dataContainer = document.querySelector($(event.target).data('json'));
    if (dataContainer == null) {
      return;
    }
    var data = JSON.parse(dataContainer.innerText);
    var post = data.find(function(e) { return e.current == true });
    
    if (typeof post != 'undefined') {
      modal.find('.modal-title').text('Reply to @' + post.username);
      if (post.profilePicture) {
        modal.find('.profile-picture').attr("src", post.profilePicture).show();
      }
      else {
        modal.find('.profile-picture').hide();
      }
      modal.find('.display-name').text(post.displayName);
      modal.find('.username').text('@' + post.username);
      modal.find('.created-at').text(post.createdAt);
      modal.find('.original-post-content').text(post.content);
      modal.find('.attachments').text('');
      post.attachments.forEach(function(attachment) {
        modal.find('.attachments').append(`<a href="${attachment.url}" target="_blank"><img src="${attachment.preview_url}"></a>`);
      });
      modal.find('input[name="original_post_id"]').val(post.id);
      modal.find('input[name="original_user_id"]').val(post.userId);
    }

    event.stopPropagation();
  });
  $('#replyModal').on('shown.bs.modal', function (event) {
    $(this).find('textarea[name="post[content]"]').trigger('focus');
  });
  
  // Open repost modal
  $('[data-action="repost"]').on('click', function (event) {
    var modal = $('#repostModal');
    modal.modal('show');
    
    var dataContainer = document.querySelector($(event.target).data('json'));
    if (dataContainer == null) {
      return;
    }
    var data = JSON.parse(dataContainer.innerText);
    var post = data.find(function(e) { return e.current == true });
    
    if (typeof post != 'undefined') {
      modal.find('.modal-title').text('Reply to @' + post.username);
      if (post.profilePicture) {
        modal.find('.profile-picture').attr("src", post.profilePicture).show();
      }
      else {
        modal.find('.profile-picture').hide();
      }
      modal.find('.display-name').text(post.displayName);
      modal.find('.username').text('@' + post.username);
      modal.find('.created-at').text(post.createdAt);
      modal.find('.original-post-content').text(post.content);
      modal.find('.attachments').text('');
      post.attachments.forEach(function(attachment) {
        modal.find('.attachments').append(`<a href="${attachment.url}" target="_blank"><img src="${attachment.preview_url}"></a>`);
      });
      modal.find('input[name="original_post_id"]').val(post.id);
      modal.find('input[name="original_user_id"]').val(post.userId);
    }
    
    event.stopPropagation();
  });
  
  $('[data-action="like"]').on('click', function (event) {
    event.stopPropagation();
  });
  
  $('[data-action="privateMessage"]').on('click', function (event) {
    event.stopPropagation();
  });
  
  // Infinite scroll
  $("#infinite-scroll-container .page").infinitescroll({
    navSelector: "nav.pagination",
    nextSelector: "nav.pagination a[rel=next]",
    itemSelector: "#infinite-scroll-container .post-row",
    loading: {finished: function(el) {
      if (!el.state.isBeyondMaxPage) {
        el.loading.msg.fadeOut(el.loading.speed);
      }
      var event = document.createEvent("Events");
      event.initEvent("turbolinks:load", true, false);
      document.dispatchEvent(event);
    }}
  });
});
