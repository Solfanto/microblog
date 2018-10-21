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
//= require turbolinks
//= require cable
  
//= require_self

$(document).on('turbolinks:load', function() {
  
  // On post thread modal
  $('#threadModal').on('show.bs.modal', function (event) {
    var modal = $(this);
    var targetId = $(event.relatedTarget).data('json');
    var data = JSON.parse(document.querySelector(targetId).innerText);

    var template = modal.find('#thread-post-template').html();
    var container = modal.find('.original-posts');
    container.html('');
    
    var selectedPost;
    
    data.forEach(function(post){
      var postDiv = $(template);
      postDiv.find('.display-name').text(post.displayName);
      postDiv.find('.username').text('@' + post.username);
      postDiv.find('.created-at').text(post.createdAt);
      postDiv.find('.content').text(post.content);
      container.append(postDiv);
      if (post.current) {
        selectedPost = post;
        postDiv.addClass('selected');
      }
    });
    
    modal.find('.username').text('@' + selectedPost.username);
    modal.find('input[name="original_post_id"]').val(selectedPost.id);
    modal.find('input[name="original_user_id"]').val(selectedPost.userId);
  });
  $('#threadModal').on('shown.bs.modal', function (event) {
    var selectedDiv = $(this).find('.post.selected');
    $('#threadModal').animate({scrollTop: selectedDiv.offset().top - 50}, 'fast');
  });
  
  // Open reply modal
  $('[data-action="reply"]').on('click', function (event) {
    var modal = $('#replyModal');
    modal.modal('show');
    
    var targetId = $(event.target).data('json');
    var data = JSON.parse(document.querySelector(targetId).innerText);
    var currentPost = data.find(function(e) { return e.current == true });
    
    modal.find('.modal-title').text('Reply to @' + currentPost.username);
    modal.find('.display-name').text(currentPost.displayName);
    modal.find('.username').text('@' + currentPost.username);
    modal.find('.created-at').text(currentPost.createdAt);
    modal.find('.original-post-content').text(currentPost.content);
    modal.find('input[name="original_post_id"]').val(currentPost.id);
    modal.find('input[name="original_user_id"]').val(currentPost.userId);

    event.stopPropagation();
  });
  $('#replyModal').on('shown.bs.modal', function (event) {
    $(this).find('textarea[name="post[content]"]').trigger('focus');
  });
  
  $('[data-action="repost"]').on('click', function (event) {
    event.stopPropagation();
  });
  
  $('[data-action="like"]').on('click', function (event) {
    event.stopPropagation();
  });
  
  $('[data-action="privateMessage"]').on('click', function (event) {
    event.stopPropagation();
  });
});
