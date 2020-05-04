class RdvWizardStep2 {

  constructor() {
    if (!$('.js-new-rdv-users-select').length) { return; }

    this.urlSearchParams = new URLSearchParams(window.location.search.substr(1))
    this.organisationId = $("input.js-current-organisation-id").val()
    $('.js-new-rdv-users-select').on('select2:select', (e) => {
      this.showSpinner()
      this.urlSearchParams.append("user_ids[]", e.params.data.id)
      window.location.search = this.urlSearchParams.toString();
    });
    this.attachRemoveUserListeners()
    $(".js-toggle-add-user-interface").on('click', (e) => {
      e.preventDefault()
      $(".js-add-user-interface").removeClass("d-none")
      $(e.currentTarget).remove()
    })

    $('js-toggle-add-user-interface').on('click', e => {
      $('js-toggle-add-user-interface').addClass('d-none')
      $('js-add-user-interface').removeClass('d-none')
    })
  }

  attachRemoveUserListeners = () => {
    $('.js-remove-user').click(event => {
      this.showSpinner()
      const userId = event.currentTarget.getAttribute('data-user-id')
      let userIds = this.urlSearchParams.getAll("user_ids[]")
      userIds.splice(userIds.indexOf(userId), 1)
      this.urlSearchParams.delete("user_ids[]")
      userIds.forEach(id => this.urlSearchParams.append("user_ids[]", id))
      window.location.search = this.urlSearchParams.toString();
    });
  }

  showSpinner = () => {
    $(".js-users-spinner").removeClass("d-none")
  }
}

export { RdvWizardStep2 };
