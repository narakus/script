"""work URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/1.10/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  url(r'^$', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  url(r'^$', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.conf.urls import url, include
    2. Add a URL to urlpatterns:  url(r'^blog/', include('blog.urls'))
"""

from django.conf.urls import include, url
from django.contrib import admin
from app import views

urlpatterns = [
    url(r'^admin/', include(admin.site.urls)),
    url(r'^view/', views.basePage),
    url(r'^svn/', views.showSvnPage),
    url(r'^addtemp/', views.showTempPage),
    url(r'^job/', views.showJobPage),
    url(r'^p/', views.rcvProjName),
    url(r'^template/', views.showProjectPage),
    url(r'^server/', views.rcvAllDate),
    url(r'^admin/', admin.site.urls),
    url(r'^speed/', views.getspeed),
    url(r'^showlog/', views.runCommand),
    url(r'^taillog/', views.tailLog),
    url(r'^search/', views.searchPag),
    url(r'^rollback/', views.rollback),
    url(r'^services/', views.services),
]
